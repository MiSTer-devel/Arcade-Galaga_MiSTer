//============================================================================
//  Arcade: Galaga
//
//  Port to MiSTer
//  Copyright (C) 2017 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [44:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        VGA_CLK,

	//Multiple resolutions are supported using different VGA_CE rates.
	//Must be based on CLK_VIDEO
	output        VGA_CE,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)

	//Base video clock. Usually equals to CLK_SYS.
	output        HDMI_CLK,

	//Multiple resolutions are supported using different HDMI_CE rates.
	//Must be based on CLK_VIDEO
	output        HDMI_CE,

	output  [7:0] HDMI_R,
	output  [7:0] HDMI_G,
	output  [7:0] HDMI_B,
	output        HDMI_HS,
	output        HDMI_VS,
	output        HDMI_DE,   // = ~(VBlank | HBlank)
	output  [1:0] HDMI_SL,   // scanlines fx

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	output  [7:0] HDMI_ARX,
	output  [7:0] HDMI_ARY,

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S    // 1 - signed audio samples, 0 - unsigned
);

assign LED_USER  = ioctl_download;
assign LED_DISK  = 0;
assign LED_POWER = 0;

assign HDMI_ARX = status[1] ? 8'd16 : status[2] ? 8'd4 : 8'd3;
assign HDMI_ARY = status[1] ? 8'd9  : status[2] ? 8'd3 : 8'd4;

`include "build_id.v" 
localparam CONF_STR = {
	"A.GALAGA;;",
	"F,rom;", // allow loading of alternate ROMs
	"-;",
	"O1,Aspect Ratio,Original,Wide;",
	"O2,Orientation,Vert,Horz;",
	"O35,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",  
	"-;",
	"O89,Lives,3,5,2,4;",
	"OAB,Difficulty,Easy,Hard,Hardest,Medium;",
	"OC,Cabinet,Upright,Cocktail;",
	//"ODF,ShipBonus,30k80kOnly/30kOnly,20k60kOnly/30k150kOnly,2k6k6k/3k10k10k,2k7k7k/3k12k12k,2k8k8k/3k15k10k,3k10k10k/3k12k12k,2k6k6k/3k10k10k,2k7k7k/3k12k12k,2k6k6k/3k10k10k,2k7k7k/3k12k12k;",
	"-;",
	"R0,Reset;",
	"J1,Fire,Start 1P,Start 2P;",
	"V,v",`BUILD_DATE
};

////////////////////   CLOCKS   ///////////////////

wire clk_sys, clk_12m, clk_24m, clk_48m;
wire pll_locked;

pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_48m),
	.outclk_1(clk_24m),
	.outclk_2(clk_sys),
	.outclk_3(clk_12m),
	.locked(pll_locked)
);

///////////////////////////////////////////////////

wire [31:0] status;
wire  [1:0] buttons;
wire        forced_scandoubler;

wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;

wire [10:0] ps2_key;

wire [15:0] joystick_0, joystick_1;
wire [15:0] joy = joystick_0 | joystick_1;

hps_io #(.STRLEN($size(CONF_STR)>>3)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.conf_str(CONF_STR),

	.buttons(buttons),
	.status(status),
	.forced_scandoubler(forced_scandoubler),

	.ioctl_download(ioctl_download),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),

	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.ps2_key(ps2_key)
);

wire       pressed = ps2_key[9];
wire [8:0] code    = ps2_key[8:0];
always @(posedge clk_sys) begin
	reg old_state;
	old_state <= ps2_key[10];
	
	if(old_state != ps2_key[10]) begin
		casex(code)
			'hX75: btn_up          <= pressed; // up
			'hX72: btn_down        <= pressed; // down
			'hX6B: btn_left        <= pressed; // left
			'hX74: btn_right       <= pressed; // right
			'h029: btn_fire        <= pressed; // space
			'h014: btn_fire        <= pressed; // ctrl

			'h005: btn_one_player  <= pressed; // F1
			'h006: btn_two_players <= pressed; // F2

			// JPAC/IPAC/MAME Style Codes
			'h016: btn_start_1     <= pressed; // 1
			'h01E: btn_start_2     <= pressed; // 2
			'h02E: btn_coin_1      <= pressed; // 5
			'h036: btn_coin_2      <= pressed; // 6
			'h02D: btn_up_2        <= pressed; // R
			'h02B: btn_down_2      <= pressed; // F
			'h023: btn_left_2      <= pressed; // D
			'h034: btn_right_2     <= pressed; // G
			'h01C: btn_fire_2      <= pressed; // A
		endcase
	end
end

reg btn_up    = 0;
reg btn_down  = 0;
reg btn_right = 0;
reg btn_left  = 0;
reg btn_fire  = 0;
reg btn_one_player  = 0;
reg btn_two_players = 0;

reg btn_start_1=0;
reg btn_start_2=0;
reg btn_coin_1=0;
reg btn_coin_2=0;
reg btn_up_2=0;
reg btn_down_2=0;
reg btn_left_2=0;
reg btn_right_2=0;
reg btn_fire_2=0;

wire m_up_2     = status[2] ? btn_left_2  | joy[1] : btn_up_2    | joy[3];
wire m_down_2   = status[2] ? btn_right_2 | joy[0] : btn_down_2  | joy[2];
wire m_left_2   = status[2] ? btn_down_2  | joy[2] : btn_left_2  | joy[1];
wire m_right_2  = status[2] ? btn_up_2    | joy[3] : btn_right_2 | joy[0];
wire m_fire_2  = btn_fire_2 | joy[4];

wire m_left   = status[2] ? btn_down  | joy[2] : btn_left  | joy[1];
wire m_right  = status[2] ? btn_up    | joy[3] : btn_right | joy[0];
wire m_fire   = btn_fire | joy[4];

wire m_start1 = btn_one_player  | joy[5] | btn_start_1;
wire m_start2 = btn_two_players | joy[6] | btn_start_2;
wire m_coin   = m_start1 | m_start2;

reg ce_pix;
always @(posedge clk_48m) begin
	reg old_clk;
	
	old_clk <= clk_12m;
	ce_pix <= old_clk & ~clk_12m;
end

wire HBlank,VBlank,hs,vs;
wire [2:0] r,g;
wire [1:0] b;

arcade_rotate_fx #(576,224,8) arcade_video
(
	.*,

	.clk_video(clk_48m),

	.RGB_in({r,g,b}),
	.HSync(~hs),
	.VSync(~vs),
	
	.fx(status[5:3]),
	.no_rotate(status[2])
);

wire [9:0] audio;
assign AUDIO_L = {audio, 6'b000000};
assign AUDIO_R = AUDIO_L;
assign AUDIO_S = 0;

wire [7:0]dip_switch_a = { status[12],1'b1,1'b1,1'b1,1'b0,1'b1,~status[11:10]};
wire [7:0]dip_switch_b = { ~status[9],status[8],6'b010111};

//dip_switch_a <= "11110111"; --  cab:7 / na:6 / test:5 / freeze:4 / demo sound:3 / na:2 / difficulty:1-0
//dip_switch_b <= "10010111"; --lives:7-6/ bonus:5-3 / coinage:2-0

galaga galaga
(
	.clock_18(clk_sys),
	.reset(RESET | status[0] | buttons[1] | ioctl_download),

	.dn_addr(ioctl_addr[16:0]),
	.dn_data(ioctl_dout),
	.dn_wr(ioctl_wr),

	.video_r(r),
	.video_g(g),
	.video_b(b),
	.video_hs(hs),
	.video_vs(vs),
	.hblank(HBlank),
	.vblank(VBlank),

	.audio(audio),

	.b_test(1),
	.b_svce(1), 

	.coin(m_coin|btn_coin_1|btn_coin_2),

	.start1(m_start1),
	.left1(m_left),
	.right1(m_right),
	.fire1(m_fire),

	.start2(m_start2),
	.left2(m_left_2),
	.right2(m_right_2),
	.fire2(m_fire_2),        
	
	.dip_switch_a(dip_switch_a),
	.dip_switch_b(dip_switch_b)
);

endmodule
