--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
    port (
        i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
    );
	end component thunderbird_fsm;

	-- test I/O signals
	signal w_left : std_logic := '0';
	signal w_right : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_clk : std_logic := '0';
	
	signal w_lights_L : std_logic_vector(2 downto 0) := "000";
	signal w_lights_R : std_logic_vector(2 downto 0) := "000";
	-- constants
	constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
   uut: thunderbird_fsm port map (
          i_left => w_left,
          i_right => w_right,
          i_reset => w_reset,
          i_clk => w_clk,
          o_lights_L => w_lights_L,
          o_lights_R => w_lights_R
        );
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	sim_proc: process
	begin
		-- reset test		
		w_reset <= '1';
		wait for k_clk_period*1;
		  assert w_lights_L = "000" report "bad reset" severity failure;
		  assert w_lights_R = "000" report "bad reset" severity failure;
	
       -- resets everything
	   w_reset <= '0';
	   w_left <= '0';
	   w_right <= '0';
	   wait for k_clk_period*1;  
	   
		-- left turn test 
		--first click
		w_left <= '1'; wait for k_clk_period;
          assert w_lights_L = "001" report "should be LA" severity failure;
          assert w_lights_R = "000" report "right should be off" severity failure;
		-- next clock cycle (input doesn't matter)
        wait for k_clk_period * 1;
            assert w_lights_L = "011" report "should be LB" severity failure;
            assert w_lights_R = "000" report "right should be off" severity failure;
        -- next clock cycle (input doesn't matter)
        wait for k_clk_period * 1;
            assert w_lights_L = "111" report "should be LC" severity failure;
            assert w_lights_R = "000" report "right should be off" severity failure;
        -- final clock cycle; back to off (input doesn't matter)
        wait for k_clk_period * 1;
            assert w_lights_L = "000" report "should be off" severity failure;
            assert w_lights_R = "000" report "right should be off" severity failure;
          
       -- resets everything
	   w_reset <= '0';
	   w_left <= '0';
	   w_right <= '0';
	   wait for k_clk_period*1;  
            
		-- right turn test 
		--first click
		w_right <= '1'; wait for k_clk_period;
          assert w_lights_R = "001" report "should be RA" severity failure;
          assert w_lights_L = "000" report "left should be off" severity failure;
		-- next clock cycle (input doesn't matter)
        wait for k_clk_period * 1;
            assert w_lights_R = "011" report "should be RB" severity failure;
            assert w_lights_L = "000" report "left should be off" severity failure;
        -- next clock cycle (input doesn't matter)
        wait for k_clk_period * 1;
            assert w_lights_R = "111" report "should be RC" severity failure;
            assert w_lights_L = "000" report "left should be off" severity failure;
        -- final clock cycle; back to off (input doesn't matter)
        wait for k_clk_period * 1;
            assert w_lights_R = "000" report "right should be off" severity failure;
            assert w_lights_L = "000" report "left should be off" severity failure;
        
       -- resets everything
	   w_reset <= '0';
	   w_left <= '0';
	   w_right <= '0';
	   wait for k_clk_period*1;  
	   
--ADD A TEST CASE FOR WHEN BOTH L AND R ARE PRESSED AT THE SAME TIME
        
        
        --makes a pretty graph  
        --assert true = false report "test complete" severity failure;
	
		wait;
	end process;
	-----------------------------------------------------	
	
end test_bench;
