'PowerEver 1.0 (aka LambdaNu PBS-1) leaded by Dr-Ing. Pichanon Suwannathada, Lambda Nu Co. Ltd.
'Released under the MIT License on 9-JULY-2020
'Imagine | Invent | Innovate @Lambda Nu Co. Ltd.

'****** MIT LICENSE ******
'Permission is hereby granted , free of charge , to any person obtaining a copy of this software and associated documentation
'files (the "Software"), to deal in the Software without restriction , including without limitation the rights to use , copy , modify , merge,
'publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so.
'The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 'IMPLIED, INCLUDING BUT NOT LIMITED TO
'THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
'OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

$regfile = "attiny13a.dat"
$crystal = 1200000

$hwstack = 40
$swstack = 6
$framesize = 6

config PORTB.0 = input
config PORTB.3 = output
config PORTB.4 = output

config Timer0 = Timer , prescale = 8

on timer0 timer0_isr

bt_learn alias PINB.0
pwm_out alias PORTB.4
led_status alias PORTB.3

const duty = 15
const PERIOD = 27
const duty_addr = 13

dim w as word
dim b as word
dim cduty as byte
dim xduty as byte
dim dw as word
dim n as byte

portb.0 = 1

if bt_learn = 0 then
   b = 0
   do
      wait 1
      incr b
   loop until b >= 3 or bt_learn = 1
   if b >= 3 then
      gosub fac_reset
      bitwait bt_learn , set
   end if
end if

readeeprom xduty , duty_addr

if xduty = 255 then xduty = duty

b = 0
cduty = 99
tcnt0 = 6
start timer0
enable timer0
enable interrupts

do
   led_status = 1
   if bt_learn = 0 then
      waitms 50
      if bt_learn = 0 then
         w = 0
         do
            waitms 10
            incr w
         loop until w >= 98 or bt_learn = 1
         if w >= 98 then
            if xduty > 0 then
               decr xduty
               writeeeprom xduty , duty_addr
               led_status = 0
                  waitms 50
               led_status = 1
                  waitms 150
               led_status = 0
                  waitms 50
               led_status = 1
            else
               gosub blink5
            end if
         else
            if xduty < 100 then
               incr xduty
               writeeeprom xduty , duty_addr
               led_status = 0
                  waitms 100
               led_status = 0
            else
               gosub blink5
            end if
         end if
         bitwait bt_learn , set
      end if
   end if
loop

end

timer0_isr:
   tcnt0 = 6
   incr b
   dw = PERIOD * 5
   if b >= dw then
      b = 0
      incr cduty
      if cduty >= 100 then cduty = 0
      if xduty > 0 and cduty < xduty then pwm_out = 0 else pwm_out = 1
   end if
return

fac_reset:
   xduty = duty
   writeeeprom xduty , duty_addr
   gosub blink5
return

blink5:
   for n = 1 to 5
      led_status = 1
      waitms 150
      led_status = 0
      waitms 150
   next
return
