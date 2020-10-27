library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.clk_p.all;
use work.tts_p.all;

entity tts_test is
	port (
		-- sys
		clk, rst : in std_logic;
		-- sw
		sw : in unsigned(7 downto 0);
		-- tts
		tts_scl, tts_sda : inout std_logic
	);
end tts_test;

architecture arch of tts_test is

	-- "給我一瓶酒/再給我一支菸/說走就走/我有的是時間/我不想在未來的日子裡/
	-- 獨自哭著無法往前", 83
	constant song : txt_t(0 to 241) := (
		x"b5", x"b9", x"a7", x"da", x"a4", x"40", x"b2", x"7e", x"b0", x"73", x"2f", x"a6", x"41", x"b5", x"b9", x"a7",
		x"da", x"a4", x"40", x"a4", x"e4", x"b5", x"d2", x"2f", x"bb", x"a1", x"a8", x"ab", x"b4", x"4e", x"a8", x"ab",
		x"2f", x"a7", x"da", x"a6", x"b3", x"aa", x"ba", x"ac", x"4f", x"ae", x"c9", x"b6", x"a1", x"2f", x"a7", x"da",
		x"a4", x"a3", x"b7", x"51", x"a6", x"62", x"a5", x"bc", x"a8", x"d3", x"aa", x"ba", x"a4", x"e9", x"a4", x"6c",
		x"b8", x"cc", x"2f", x"bf", x"57", x"a6", x"db", x"ad", x"fa", x"b5", x"db", x"b5", x"4c", x"aa", x"6b", x"a9",
		x"b9", x"ab", x"65", others => x"00"
	);

	-- "聽講，露西時常做運動，身體健康精神好，露西！哩洗那欸加你搞，身體健康精神
	-- 好，規律運動不可少，沒事常做健康操，全身運動功效好，喂，同學，歸勒百欸穩懂
	-- 安抓來安白，杯題阿哇的有擘吼哩哉，咖嘛北鼻當賊來，麼地有135，麼地有24
	-- 6，西哉金裡嗨，搭給當賊來。", 242
	constant what : txt_t(0 to 241) := (
		x"c5", x"a5", x"c1", x"bf", x"a1", x"41", x"c5", x"53", x"a6", x"e8", x"ae", x"c9", x"b1", x"60", x"b0", x"b5",
		x"b9", x"42", x"b0", x"ca", x"a1", x"41", x"a8", x"ad", x"c5", x"e9", x"b0", x"b7", x"b1", x"64", x"ba", x"eb",
		x"af", x"ab", x"a6", x"6e", x"a1", x"41", x"c5", x"53", x"a6", x"e8", x"a1", x"49", x"ad", x"f9", x"ac", x"7e",
		x"a8", x"ba", x"d5", x"d9", x"a5", x"5b", x"a7", x"41", x"b7", x"64", x"a1", x"41", x"a8", x"ad", x"c5", x"e9",
		x"b0", x"b7", x"b1", x"64", x"ba", x"eb", x"af", x"ab", x"a6", x"6e", x"a1", x"41", x"b3", x"57", x"ab", x"df",
		x"b9", x"42", x"b0", x"ca", x"a4", x"a3", x"a5", x"69", x"a4", x"d6", x"a1", x"41", x"a8", x"53", x"a8", x"c6",
		x"b1", x"60", x"b0", x"b5", x"b0", x"b7", x"b1", x"64", x"be", x"de", x"a1", x"41", x"a5", x"fe", x"a8", x"ad",
		x"b9", x"42", x"b0", x"ca", x"a5", x"5c", x"ae", x"c4", x"a6", x"6e", x"a1", x"41", x"b3", x"de", x"a1", x"41",
		x"a6", x"50", x"be", x"c7", x"a1", x"41", x"c2", x"6b", x"b0", x"c7", x"a6", x"ca", x"d5", x"d9", x"c3", x"ad",
		x"c0", x"b4", x"a6", x"77", x"a7", x"ec", x"a8", x"d3", x"a6", x"77", x"a5", x"d5", x"a1", x"41", x"aa", x"4d",
		x"c3", x"44", x"aa", x"fc", x"ab", x"7a", x"aa", x"ba", x"a6", x"b3", x"c0", x"bc", x"a7", x"71", x"ad", x"f9",
		x"ab", x"76", x"a1", x"41", x"a9", x"40", x"b9", x"c0", x"a5", x"5f", x"bb", x"f3", x"b7", x"ed", x"b8", x"e9",
		x"a8", x"d3", x"a1", x"41", x"bb", x"f2", x"a6", x"61", x"a6", x"b3", x"31", x"33", x"35", x"a1", x"41", x"bb",
		x"f2", x"a6", x"61", x"a6", x"b3", x"32", x"34", x"36", x"a1", x"41", x"a6", x"e8", x"ab", x"76", x"aa", x"f7",
		x"b8", x"cc", x"b6", x"d9", x"a1", x"41", x"b7", x"66", x"b5", x"b9", x"b7", x"ed", x"b8", x"e9", x"a8", x"d3",
		x"a1", x"43"
	);

	constant datasheet_example : txt_t(0 to 60) := (
		x"8a", x"05", -- MO[0:2] = "101"
		x"B5", x"BE", x"AD", x"B5", x"AC", x"EC", x"A7", x"DE", x"31", x"37", x"38", x"42", x"B4", x"FA", x"B8", x"D5", -- 翔音科技178B測試
		x"86", x"e0", -- volume = 0xe0
		x"83", x"14", -- speed = 120%
		x"B5", x"BE", x"AD", x"B5", x"AC", x"EC", x"A7", x"DE", x"31", x"37", x"38", x"42", x"B4", x"FA", x"B8", x"D5", -- 翔音科技178B測試
		x"83", x"00", -- speed = 100%
		x"B5", x"A5", x"AB", x"DD", x"A4", x"51", x"AC", x"ED", x"C4", x"C1", -- 等待十秒鐘
		x"87", x"00", x"00", x"27", x"10", -- delay 10000ms
		x"AE", x"C9", x"B6", x"A1", x"A8", x"EC" -- 時間到
	);

	signal txt_sel : integer range 0 to 1;

	signal tts_ena : std_logic;
	signal tts_busy : std_logic;
	signal tts_txt : txt_t(0 to 241);
	signal tts_txt_len : integer range 0 to 242;
	signal tts_done : std_logic;

	type state_type is (send, delay);
	signal state : state_type;

	signal timer : integer range 0 to sys_clk_freq - 1;

begin

	tts_inst : entity work.tts(arch)
		generic map(
			txt_len_max => 242
		)
		port map(
			tts_scl => tts_scl,
			tts_sda => tts_sda,
			clk     => clk,
			rst     => rst,
			ena     => tts_ena,
			busy    => tts_busy,
			txt     => tts_txt,
			txt_len => tts_txt_len
		);

	edge_inst : entity work.edge(arch)
		port map(
			clk       => clk,
			rst       => rst,
			signal_in => tts_busy,
			rising    => open,
			falling   => tts_done
		);

	process (clk, rst) begin
		if rst = '0' then
			timer <= timer'high;
			state <= send;
		elsif rising_edge(clk) then
			case state is
				when send =>
					tts_txt <= what;
					tts_txt_len <= 242;
					tts_ena <= '1';

					if tts_done = '1' then
						state <= delay;
					end if;

				when delay =>
					if timer = 0 then
						state <= send;
						timer <= timer'high;
					else
						timer <= timer + 1;
					end if;
			end case;
		end if;
	end process;

end arch;