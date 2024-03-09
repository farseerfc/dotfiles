#!/usr/bin/env python3
import sys
from collections import namedtuple

commands = dict()
POWER_SUPPLY = "/sys/class/power_supply/"
BATTARY = POWER_SUPPLY + "max170xx_battery/"
USBC = POWER_SUPPLY + "tcpm-source-psy-i2c-fusb302/"
CHARGER = POWER_SUPPLY + "bq24190-charger/"

Command = namedtuple('Command', ['name', 'func', 'desc', 'dtype', 'rangemin', 'rangemax'])

def command(dtype, desc, rangemin, rangemax):
    def wrap(f):
        name = f.__name__.replace('__','/')
        commands[name] = Command(name, f, desc, dtype, rangemin, rangemax)
        return f
    return wrap
    
def cat(path):
    try:
        data = open(path).read()
        v = float(data)
        return data
    except:
        return '0'

@command('battary voltage now', 'float', 0, 15.0)
def bat__voltage():
    return float(cat(BATTARY + 'voltage_now'))/1000000.0

@command('battary current now', 'float', -5.0, 5.0)
def bat__current():
    return float(cat(BATTARY + 'current_now'))/1000000.0

@command('battary power (W)', 'float', -25.0, 25.0)
def bat__power():
    return bat__current() * bat__voltage()

@command('usb-c source voltage now', 'float', 0, 15.0)
def source__voltage():
    return float(cat(USBC + 'voltage_now'))/1000000.0

@command('usb-c source current max', 'float', 0, 5.0)
def source__current():
    return float(cat(USBC + 'current_max'))/1000000.0

@command('usb-c power (W)', 'float', -25.0, 25.0)
def source__power():
    return source__current()*source__voltage()

@command('charger voltage now', 'float', 0, 15.0)
def charger__voltage():
    return float(cat(CHARGER + 'constant_charge_voltage'))/1000000.0

@command('charger current max', 'float', 0, 5.0)
def charger__current():
    return float(cat(CHARGER + 'constant_charge_current'))/1000000.0

@command('charger power (W)', 'float', -25.0, 25.0)
def charger__power():
    return charger__current() * charger__voltage()

@command('charge full', 'float', 0, 30)
def charge__full():
    return float(cat(BATTARY + 'charge_full'))*3.5/1000000

@command('charge full design', 'float', 0, 30)
def charge__full_design():
    return float(cat(BATTARY + 'charge_full_design'))*3.5/1000000

@command('charge now', 'float', 0, 30)
def charge__now():
    return float(cat(BATTARY + 'charge_now'))*3.5/1000000

def main():
    print("ksysguardd 1.2.0")
    print("ksysguardd> ", end='', flush=True)
    
    while True:
        try:
            cmd = input()
            if cmd == 'monitors':
                print('\n'.join( f'{x.name}\t{x.desc}' for x in commands.values()))
            elif cmd.endswith('?') and cmd[:-1] in commands:
                c = commands[cmd[:-1]] 
                print(f'{c.dtype}\t{c.rangemin}\t{c.rangemax}')
            elif cmd in commands:
                print(commands[cmd].func())
            elif cmd != '':
                print('UNKNOWN COMMAND')
            print("ksysguardd> ", end='', flush=True)
        except EOFError:
            sys.exit(0)
        except KeyboardInterrupt:
            sys.exit(0)

if __name__=='__main__':
    main()
