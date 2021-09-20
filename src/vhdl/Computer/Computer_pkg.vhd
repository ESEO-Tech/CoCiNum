
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Virgule_pkg.all;

package Computer_pkg is

    constant CLK_FREQUENCY_HZ    : positive      := 100e6;

    constant MEM_ADDRESS         : byte_t        := x"00";
    constant MEM_CONTENT         : word_vector_t := work.Loader_pkg.DATA;

    constant INTC_ADDRESS        : byte_t        := x"81";

    constant UART_ADDRESS        : byte_t        := x"82";
    constant UART_BIT_RATE_HZ    : positive      := 115200;

    constant INTC_EVENTS_UART_RX : natural       := 0;
    constant INTC_EVENTS_UART_TX : natural       := 1;

end Computer_pkg;
