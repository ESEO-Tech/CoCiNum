import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

import tkinter as tk
from datetime import datetime, timedelta
from time import sleep
from math import floor

led_color_on      = "lime"
led_color_off     = "dark slate gray"
led_color_invalid = "red"

refresh_time = timedelta(milliseconds=40)

led_count  = 16
led_radius = 10
led_margin = 5

led_width = 2 * (led_radius + led_margin)

class Gui:
    def __init__(self, dut):
        self.dut = dut

        self.root = tk.Tk()
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)

        self.canvas = tk.Canvas(self.root, width=led_count * led_width, height=led_width, bg="black", relief="flat")
        self.canvas.pack(side=tk.TOP)
        self.leds = [self.canvas.create_oval(i * led_width + led_margin, led_margin, (i + 1) * led_width - led_margin, led_width - led_margin, fill=led_color_off) for i in range(led_count)]

        btn_left = tk.Button(self.root, text="Left")
        btn_left.pack(side=tk.LEFT, fill=tk.BOTH)
        btn_left.bind("<ButtonPress>", self.on_press_left)
        btn_left.bind("<ButtonRelease>", self.on_release_left)

        btn_center = tk.Button(self.root, text="Restart")
        btn_center.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        btn_center.bind("<ButtonPress>", self.on_press_center)
        btn_center.bind("<ButtonRelease>", self.on_release_center)

        btn_right = tk.Button(self.root, text="Right")
        btn_right.pack(side=tk.RIGHT, fill=tk.BOTH)
        btn_right.bind("<ButtonPress>", self.on_press_right)
        btn_right.bind("<ButtonRelease>", self.on_release_right)

        self.btn_center_state = 0
        self.btn_left_state   = 0
        self.btn_right_state  = 0

        self.closed = False
        self.last_update = datetime.now()

        self.root.update()

    def on_close(self):
        self.root.quit()
        self.closed = True

    def on_press_left(self, evt):
        self.btn_left_state = 1

    def on_release_left(self, evt):
        self.btn_left_state = 0

    def on_press_center(self, evt):
        self.btn_center_state = 1

    def on_release_center(self, evt):
        self.btn_center_state = 0

    def on_press_right(self, evt):
        self.btn_right_state = 1

    def on_release_right(self, evt):
        self.btn_right_state = 0

    def update(self):
        t = datetime.now()
        delta = t - self.last_update

        if delta >= refresh_time:
            self.last_update = t
            for i in range(led_count):
                led = self.dut.leds_o.value.binstr[i]
                if led == '1':
                    color = led_color_on
                elif led == '0':
                    color = led_color_off
                else:
                    color = led_color_invalid

                self.canvas.itemconfig(self.leds[i], fill=color)

        self.dut.btn_left_i   <= self.btn_left_state
        self.dut.btn_center_i <= self.btn_center_state
        self.dut.btn_right_i  <= self.btn_right_state

        self.root.update()

# Generate a clock that attempts to match the real time.
#
# trigger:       A Timer object corresponding to half a clock period
# burst_time:    A timedelta object corresponding to the duration of a burst of clock cycles
# burst_count:   The number of clock cycles in a burst
#
# Precondition: burst_time / burst_count == 2 * trigger
@cocotb.coroutine
def realtime_clock(sig, trigger, burst_time, burst_count):
    second = timedelta(seconds=1)

    while True:
        burst_start_time = datetime.now()
        for i in range(burst_count):
            sig <= 0
            yield trigger
            sig <= 1
            yield trigger
        burst_end_time = datetime.now()
        delta = burst_end_time - burst_start_time
        if delta < burst_time:
            sleep((burst_time - delta) / second)

@cocotb.test()
def run(dut):
    gui = Gui(dut)

    clk = realtime_clock(dut.clk_i, Timer(500, "us"), timedelta(milliseconds=10), 10)
    cocotb.fork(clk)

    dut.btn_center_i <= 0

    while not gui.closed:
        yield Timer(10, "ms")
        gui.update()
