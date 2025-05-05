----------------------------------------------------------------------------------
-- Noridel Herron
-- Testbench for DATA_MEM.vhd
-- 5/5/2025
--
-- Description:
-- Tests 32-bit word-addressable memory using randomized reads and writes.
-- Uses a reusable formatting function for hexadecimal output.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

-- Import custom package
library work;
use work.reusable_function.all;

-- no port needed since it is only for simulation test purpose
entity tb_DATA_MEM is
end tb_DATA_MEM;

architecture sim of tb_DATA_MEM is

    -- DUT component
    component DATA_MEM
        Port (
            clk        : in  std_logic;
            mem_read   : in  std_logic;
            mem_write  : in  std_logic;
            address    : in  std_logic_vector(9 downto 0);
            write_data : in  std_logic_vector(31 downto 0);
            read_data  : out std_logic_vector(31 downto 0)
        );
    end component;

    -- DUT I/O signals
    signal clk        : std_logic := '0';
    signal mem_read   : std_logic := '0';
    signal mem_write  : std_logic := '0';
    signal address    : std_logic_vector(9 downto 0) := (others => '0');
    signal write_data : std_logic_vector(31 downto 0) := (others => '0');
    signal read_data  : std_logic_vector(31 downto 0);

    -- Expected memory for verification
    type mem_array is array (0 to 1023) of std_logic_vector(31 downto 0);
    signal expected_mem : mem_array := (others => (others => '0'));

    -- Test settings
    constant num_tests : integer := 5000;

begin

    -------------------------------------------------------------------------------
    -- Clock generator: 10 ns period
    -------------------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    -------------------------------------------------------------------------------
    -- Unit Under Test
    -------------------------------------------------------------------------------
    UUT: DATA_MEM port map ( clk, mem_read, mem_write, address, write_data, read_data);
    -------------------------------------------------------------------------------
    -- Main test routine: generates random data, writes to memory, reads it back, and compares.
    -------------------------------------------------------------------------------
    stim_proc: process
        ---------------------------------------------------------------------------
        --  Seeds for the uniform() function — ensures reproducibility of random values.
        ---------------------------------------------------------------------------
        variable seed1      : positive := 42;
        variable seed2      : positive := 24;
        ---------------------------------------------------------------------------
        --  Temporary variables for holding random values.
        ---------------------------------------------------------------------------
        variable rand       : real;
        variable rand_addr  : integer;
        variable rand_value : integer;
        variable rand_data  : std_logic_vector(31 downto 0);
        ---------------------------------------------------------------------------
        -- Keep track of pass or fail test
        ---------------------------------------------------------------------------
        variable pass_count  : integer := 0;
        variable fail_count  : integer := 0;       
    begin
        ---------------------------------------------------------------------------
        -- WRITE PHASE
        ---------------------------------------------------------------------------
        for i in 0 to num_tests - 1 loop
            -- Generate random address
            uniform(seed1, seed2, rand);
            -- "mod 1024" will ensure that the rand_addr will be less than 1024
            rand_addr := integer(rand * 1024.0) mod 1024; 
            address <= std_logic_vector(to_unsigned(rand_addr, 10));

            -- Generate random data
            uniform(seed1, seed2, rand);
            rand_value := integer(rand * 4294967296.0);
            rand_data := std_logic_vector(to_unsigned(rand_value, 32));
            write_data <= rand_data;

            -- Write to memory
            mem_read  <= '0';
            mem_write <= '1';
            wait for 10 ns;

            -- Save for later verification
            expected_mem(rand_addr) <= rand_data;
        end loop;

        mem_write <= '0';
        wait for 50 ns;

        ---------------------------------------------------------------------------
        -- READ & VERIFY PHASE
        ---------------------------------------------------------------------------
        for i in 0 to num_tests - 1 loop
            -- Random address
            uniform(seed1, seed2, rand);
            rand_addr := integer(rand * 1024.0) mod 1024;
            address <= std_logic_vector(to_unsigned(rand_addr, 10));

            -- Perform read
            mem_read  <= '1';
            mem_write <= '0';
            wait for 10 ns;

            -- Assertion to verify read value
            assert read_data = expected_mem(rand_addr)
                report "ASSERTION FAILED @ address " & integer'image(rand_addr) &
                       " | Expected: 0x" & to_hexstring(expected_mem(rand_addr)) &
                       " | Got: 0x" & to_hexstring(read_data)
                severity error;

            pass_count := pass_count + 1;
        end loop;
        ---------------------------------------------------------------------------
        -- Final Test Summary
        ---------------------------------------------------------------------------
        report "------------------------------------------";
        report "TEST SUMMARY:";
        report "  PASSED: " & integer'image(pass_count);
        report "  FAILED: " & integer'image(fail_count);
        report "------------------------------------------";

        wait;
    end process;

end sim;
