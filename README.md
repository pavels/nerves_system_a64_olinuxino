# Generic A64-OLinuXino Support

[![CircleCI](https://circleci.com/gh/pavels/nerves_system_a64_olinuxino.svg?style=svg)](https://circleci.com/gh/pavels/nerves_system_a64_olinuxino)
[![Hex version](https://img.shields.io/hexpm/v/nerves_system_a64_olinuxino.svg "Hex version")](https://hex.pm/packages/nerves_system_a64_olinuxino)

This is the base Nerves System configuration for the [A64-OLinuXino](https://www.olimex.com/Products/OLinuXino/A64/A64-OLinuXino)

![A64-OLinuXino image](assets/images/A64-OLinuXino-.jpg)

| Feature              | Description                     |
| -------------------- | ------------------------------- |
| CPU                  | Allwinner A64 - 1.2 GHz Quad-Core ARM Cortex-A53 64-bit             |
| Memory               | 1GB or 2GB RAM DDR3L @ 672Mhz   |
| Storage              | MicroSD (eMMC not supported)    |
| Linux kernel         | 5.2 mainline                    |
| IEx terminal         | UART `ttyS0`                    |
| GPIO, I2C, SPI       | Yes, I2C and SPI on UEXT        |
| ADC                  | No                              |
| PWM                  | No                              |
| UART                 | ttyS0 + ttyS2 on UEXT           |
| Camera               | None                            |
| Ethernet             | Yes                             |
| WiFi                 | RTL8723BS on board (some board configurations). Other requires USB WiFi dongle/driver |
| HW Watchdog          | sunxi watchdog available        |
| Power Management     | AXP803 driver available - support for battery and ac charger status        |

## Using

The most common way of using this Nerves System is create a project with `mix
nerves.new` and to export `MIX_TARGET=a64_olinuxino`. See the [Getting started
guide](https://hexdocs.pm/nerves/getting-started.html#creating-a-new-nerves-app)
for more information.

If you need custom modifications to this system for your device, clone this
repository and update as described in [Making custom
systems](https://hexdocs.pm/nerves/systems.html#customizing-your-own-nerves-system)

If you're new to Nerves, check out the
[nerves_init_gadget](https://github.com/nerves-project/nerves_init_gadget)
project for creating a starter project. It will get you started with the basics
like bringing up networking, initializing the writable application data
partition, and enabling ssh-based firmware updates.  It's easiest to begin by
using the wired Ethernet interface 'eth0' and DHCP.

## Console access

The console is configured to output to the 6 pin header on the
A64-OLinuXino that's labeled `DBG_UART`. A 3.3V FTDI cable is needed to access the output.

## Provisioning devices

This system supports storing provisioning information in a small key-value store
outside of any filesystem. Provisioning is an optional step and reasonable
defaults are provided if this is missing.

Provisioning information can be queried using the Nerves.Runtime KV store's
[`Nerves.Runtime.KV.get/1`](https://hexdocs.pm/nerves_runtime/Nerves.Runtime.KV.html#get/1)
function.

Keys used by this system are:

Key                    | Example Value     | Description
:--------------------- | :---------------- | :----------
`nerves_serial_number` | `"12345678"`      | By default, this string is used to create unique hostnames and Erlang node names. If unset, it defaults to part of the Etherner MAC Address.

The normal procedure would be to set these keys once in manufacturing or before
deployment and then leave them alone.

For example, to provision a serial number on a running device, run the following
and reboot:

```elixir
iex> cmd("fw_setenv nerves_serial_number 12345678")
```

This system supports setting the serial number offline. To do this, set the
`NERVES_SERIAL_NUMBER` environment variable when burning the firmware. If you're
programming MicroSD cards using `fwup`, the commandline is:

```sh
sudo NERVES_SERIAL_NUMBER=12345678 fwup path_to_firmware.fw
```

Serial numbers are stored on the MicroSD card so if the MicroSD card is
replaced, the serial number will need to be reprogrammed. The numbers are stored
in a U-boot environment block. This is a special region that is separate from
the application partition so reformatting the application partition will not
lose the serial number or any other data stored in this block.

Additional key value pairs can be provisioned by overriding the default provisioning.conf
file location by setting the environment variable
`NERVES_PROVISIONING=/path/to/provisioning.conf`. The default provisioning.conf
will set the `nerves_serial_number`, if you override the location to this file,
you will be responsible for setting this yourself.

## UEXT

All parts of `UEXT` port are enabled and supported.

SPI is on `spidev0.0`

I2c is on `i2c-0`

UART is on `ttyS1`

## GPIO

For GPIO access use [circuits_cdev](https://github.com/elixir-circuits/circuits_cdev).

All GPIOs are on `gpiochip2`.

Use following formula to calculate proper GPIO number from pin name (like PE0):

```
(position of letter in alphabet - 1) * 32 + pin number
```

> For `PE0` this would be '`4 * 32 + 0 = 128`'

## SPI

If you have included [circuits_spi](https://github.com/elixir-circuits/circuits_spi) as a
dependency, you can start it now and test a transfer:

> The example below should work without any additional hardware connected to the
> OLinuXino. If you have SPI hardware connected to the OLinuXino, your returned binary might
> be different.

```elixir
iex> {:ok, ref} = Circuits.SPI.open("spidev0.0")
{:ok, #Reference<...>}
iex> Circuits.SPI.transfer(ref, <<1,2,3,4>>)
<<0, 0, 0, 0>>
```

## I2C

If you have included [circuits_i2c](https://github.com/elixir-circuits/circuits_i2c) as a
dependency, you can use it to scan for devices:

```elixir
iex> Circuits.I2C.detect_devices()
Devices on I2C bus "i2c-0":
```

## Audio

Onboard audio input and output is supported and is set as default in ALSA.

To use it, you first need to enable it.

To enable output execute:

```elixir
System.cmd("amixer", ["-q", "sset", "AIF1 Slot 0 Digital DAC", "on"])
System.cmd("amixer", ["-q", "sset", "Headphone", "100%", "on"])
```

To enable microphone input execute

```elixir
System.cmd("amixer", ["-q", "sset", "AIF1 Data Digital ADC", "cap", "on"])
System.cmd("amixer", ["-q", "sset", "Mic1", "43%", "cap", "on"])
```

## Supported WiFi devices

Some boards has built in RTL8723BS. This module is not always very reliable and the signal strength is problematic due to on board antenna design.

Various USB WIFI dongle are supported. Recommended and tested ones are USB adapters supported by `rt2800usb` driver (Ralink RT2070, RT2770, RT2870, RT3070, RT3071, RT3072, RT3370, RT3572, RT5370, RT5372, RT5572).

## Installation

If you're new to Nerves, check out the
[nerves_init_gadget](https://github.com/fhunleth/nerves_init_gadget) project for
creating a starter project for the A64-OLinuXino boards.

It will get you started with the basics like bringing up the virtual Ethernet interface, initializing the application partition, and enabling ssh-based firmware updates.
