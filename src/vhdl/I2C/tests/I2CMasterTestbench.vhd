
--
-- Copyright (C), 2021, ESEO
-- Guillaume Savaton <guillaume.savaton@eseo.fr>
--

entity I2CMasterTestbench is
end I2CMasterTestbench;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture Simulation of I2CMasterTestbench is
    constant CLK_FREQUENCY_HZ             : positive                     := 50e6;
    constant I2C_FREQUENCY_HZ             : positive                     := 100e3;
    constant SLAVE_ADDRESS                : std_logic_vector(6 downto 0) := "0101010";
    constant SEND_DATA                    : word_t                       := "1100101010010110010100110101";
    constant RECV_DATA                    : word_t                       := not SEND_DATA;
    constant SEND_LEN                     : integer                      := 1;
    constant RECV_LEN                     : integer                      := 0;
    constant CLK_PERIOD                   : time                         := 1 sec / CLK_FREQUENCY_HZ;
    constant BIT_PERIOD                   : time                         := 1 sec / I2C_FREQUENCY_HZ;
    constant TIMEOUT                      : time                         := (SEND_LEN + RECV_LEN + 3) * 15 * BIT_PERIOD;
    constant ACKNOWLEDGE_WRITE_ADDRESS    : boolean                      := true;
    constant ACKNOWLEDGE_WRITE_DATA       : boolean                      := true;
    constant ACKNOWLEDGE_READ_ADDRESS     : boolean                      := true;
    constant OTHER_SERIAL_CLOCK           : boolean                      := true;
    constant OTHER_SERIAL_CLOCK_HIGH_TIME : time                         := BIT_PERIOD * 3 / 4;
    constant OTHER_SERIAL_CLOCK_LOW_TIME  : time                         := BIT_PERIOD * 3 / 4;

    signal clk              : std_logic := '0';
    signal reset            : std_logic := '1';
    signal write            : std_logic;
    signal address          : std_logic;
    signal wdata, rdata     : word_t;
    signal done, err        : std_logic;
    signal scl, sda         : std_logic;
    signal scl_bin, sda_bin : std_logic;
begin
    master_inst : entity work.I2CMaster
        generic map(
            CLK_FREQUENCY_HZ => CLK_FREQUENCY_HZ,
            I2C_FREQUENCY_HZ => I2C_FREQUENCY_HZ
        )
        port map(
            clk_i     => clk,
            write_i   => write,
            address_i => address,
            wdata_i   => wdata,
            rdata_o   => rdata,
            done_o    => done,
            error_o   => err,
            sda_io    => sda,
            scl_io    => scl
        );

    clk   <= not clk after CLK_PERIOD / 2;
    reset <= '0'     after CLK_PERIOD;

    sda     <= 'H';
    scl     <= 'H';
    scl_bin <= to_X01(scl);
    sda_bin <= to_X01(sda);

    p_master : process
    begin
        -- Set lengths and slave address.
        wait until rising_edge(clk) and reset = '0';
        address <= '1';
        wdata(15 downto 0) <= std_logic_vector(to_unsigned(SEND_LEN, 4)) &
                              std_logic_vector(to_unsigned(RECV_LEN, 4)) &
                              '0' & SLAVE_ADDRESS;
        write <= '1';

        -- Set data to send and start transaction.
        wait until rising_edge(clk);
        wdata <= SEND_DATA;

        wait until rising_edge(clk);
        write <= '0';

        wait until rising_edge(clk) and (done = '1' or err = '1');
        if err = '1' then
            report "I2C error";
        elsif RECV_LEN > 0 then
            assert rdata = RECV_DATA
                report "rdata"
                severity ERROR;
        end if;
        report "Done" severity FAILURE;
    end process p_master;

    process
    begin
        scl <= 'Z';
        wait until scl_bin = '0';
        loop
            if OTHER_SERIAL_CLOCK then
                scl <= '0';
            end if;
            wait for OTHER_SERIAL_CLOCK_LOW_TIME;
            scl <= 'Z';
            wait until scl_bin = '1';
            wait for OTHER_SERIAL_CLOCK_HIGH_TIME;
        end loop;
    end process;

    process
    begin
        sda <= 'Z';

        if SEND_LEN > 0 then
            -- Start condition
            wait until sda_bin = '0' and scl_bin = '1';

            -- Receive slave address
            for i in 6 downto 0 loop
                wait until rising_edge(scl_bin);
                assert sda_bin = SLAVE_ADDRESS(i)
                    report "Slave address not transmitted correctly"
                    severity WARNING;
            end loop;

            -- Receive direction
            wait until rising_edge(scl_bin);
            assert sda_bin = '0' -- Transmission
                report "Wrong R/W"
                severity WARNING;

            -- Acknowledge
            wait until falling_edge(scl_bin);
            if ACKNOWLEDGE_WRITE_ADDRESS then
                sda <= '0';
            end if;
            wait until rising_edge(scl_bin);
            wait until falling_edge(scl_bin);
            sda <= 'Z';

            for i in 0 to SEND_LEN-1 loop
                -- Receive data byte
                for j in 0 to 7 loop
                    wait until rising_edge(scl_bin);
                    assert sda_bin = SEND_DATA(23 - i * 8 - j)
                        report "Data bit not transmitted correctly"
                        severity WARNING;
                end loop;

                -- Acknowledge
                wait until falling_edge(scl_bin);
                if ACKNOWLEDGE_WRITE_DATA then
                    sda <= '0';
                end if;
                wait until rising_edge(scl_bin);
                wait until falling_edge(scl_bin);
                sda <= 'Z';
            end loop;
        end if;

        if RECV_LEN > 0 then
            -- Repeated start condition
            wait until sda_bin = '0' and scl_bin = '1';

            -- Receive slave address
            for i in 6 downto 0 loop
                wait until rising_edge(scl_bin);
                assert sda_bin = SLAVE_ADDRESS(i)
                    report "Slave address not transmitted correctly"
                    severity WARNING;
            end loop;

            -- Receive direction
            wait until rising_edge(scl_bin);
            assert sda_bin = '1' -- Reception
                report "Wrong R/W"
                severity WARNING;

            -- Acknowledge
            wait until falling_edge(scl_bin);
            if ACKNOWLEDGE_READ_ADDRESS then
                sda <= '0';
            end if;
            wait until rising_edge(scl_bin);

            for i in SEND_LEN-1 downto 0 loop
                -- Send data byte
                for j in 7 downto 0 loop
                    wait until falling_edge(scl_bin);
                    if RECV_DATA(i * 8 + j) = '1' then
                        sda <= 'Z';
                    else
                        sda <= '0';
                    end if;
                end loop;

                -- Acknowledge
                wait until falling_edge(scl_bin);
                sda <= 'Z';
                wait until rising_edge(scl_bin);
                assert sda_bin = '0'
                    report "Master did not acknowledge"
                    severity WARNING;
            end loop;
        end if;

        wait;
    end process;

    process
    begin
        wait for TIMEOUT;
        report "Timeout" severity FAILURE;
    end process;
end Simulation;
