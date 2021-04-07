
#include "Platform.h"
#include "Platform-config.h"

#define REG(T, ADDR, N) (T*)(ADDR + 4 * N)

/* -------------------------------------------------------------------------- *
 * Global interrupt controller
 * -------------------------------------------------------------------------- */

InterruptController *const intc = (InterruptController*)INTC_ADDRESS;

/* -------------------------------------------------------------------------- *
 * UART
 * -------------------------------------------------------------------------- */

static UART uart_priv = {
    .intc        = intc,
    .rx_evt_mask = INTC_EVENTS_UART_RX,
    .tx_evt_mask = INTC_EVENTS_UART_TX,
    .data        = REG(uint8_t, UART_ADDRESS, 0)
};

UART *const uart = &uart_priv;

/* -------------------------------------------------------------------------- *
 * Timer
 * -------------------------------------------------------------------------- */

static Timer timer_priv = {
    .intc     = intc,
    .evt_mask = INTC_EVENTS_TIMER,
    .limit    = REG(uint32_t, TIMER_ADDRESS, TIMER_LIMIT_REG),
    .count    = REG(uint32_t, TIMER_ADDRESS, TIMER_COUNT_REG)
};

Timer *const timer = &timer_priv;

/* -------------------------------------------------------------------------- *
 * Segment display
 * -------------------------------------------------------------------------- */

SegmentDisplay *const display = (SegmentDisplay*)DISPLAY_ADDRESS;

/* -------------------------------------------------------------------------- *
 * User I/O
 * -------------------------------------------------------------------------- */

UserOutputs *const leds = (UserOutputs*)LEDS_ADDRESS;

static UserInputs btns_priv = {
    .intc         = intc,
    .intc_on      = (InterruptController*)BTNS_ON_ADDRESS,
    .intc_off     = (InterruptController*)BTNS_OFF_ADDRESS,
    .on_evt_mask  = INTC_EVENTS_BTNS_ON,
    .off_evt_mask = INTC_EVENTS_BTNS_OFF,
    .on_off_mask  = BTNS_ON_OFF_MASK,
    .status       = REG(uint32_t, BTNS_ADDRESS, 0)
};

UserInputs *const btns = &btns_priv;

/* -------------------------------------------------------------------------- *
 * SPI
 * -------------------------------------------------------------------------- */

static SPIMaster spi1_priv = {
    .intc      = intc,
    .evt_mask  = INTC_EVENTS_SPI1,
    .data      = REG(uint8_t, SPI1_ADDRESS, SPI_DATA_REG),
    .control   = REG(uint8_t, SPI1_ADDRESS, SPI_CONTROL_REG),
    .timer_max = REG(uint8_t, SPI1_ADDRESS, SPI_TIMER_MAX_REG)
};

SPIMaster *const spi1 = &spi1_priv;

static SPIMaster spi2_priv = {
    .intc      = intc,
    .evt_mask  = INTC_EVENTS_SPI2,
    .data      = REG(uint8_t, SPI2_ADDRESS, SPI_DATA_REG),
    .control   = REG(uint8_t, SPI2_ADDRESS, SPI_CONTROL_REG),
    .timer_max = REG(uint8_t, SPI2_ADDRESS, SPI_TIMER_MAX_REG)
};

SPIMaster *const spi2 = &spi2_priv;
