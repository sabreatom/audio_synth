import math
import matplotlib.pyplot as plt

#------------------------------------
#generate package with waveform LUTs:
#------------------------------------

COUNTER_WIDTH_BITS = 8
WAVEFORM_AMPLITUDE_BITS = 24

angle_step_size = (2 * math.pi) / (2**COUNTER_WIDTH_BITS)
amplitude = 2 ** WAVEFORM_AMPLITUDE_BITS - 1

sine_array = []

#generate sinewave array:
for step in range(0, 2**COUNTER_WIDTH_BITS):
    sine_array.append(round(amplitude / 2 * math.sin(angle_step_size * step) + amplitude / 2))

#store to file:
f = open("waveform_lut.vhd", "w")
f.write("package waveform_lut_pkg is\n")

f.write('type t_sine_array is array (0 to %d) of natural;\n' % (2 ** COUNTER_WIDTH_BITS - 1))
f.write('constant sine_lut : t_sine_array :=\n')
for i in range(0, 2**COUNTER_WIDTH_BITS):
    if (i == 0):
        f.write('\t(%d,\n' % (sine_array[i]))
    elif (i == 2**COUNTER_WIDTH_BITS - 1):
        f.write('\t%d);\n' % (sine_array[i]))
    else:
        f.write('\t%d,\n' % (sine_array[i]))

f.write("\n")
f.write("end package waveform_lut_pkg;\n")
f.write("\n")
f.write("package body waveform_lut_pkg is\n")
f.write("\n")
f.write("end package body waveform_lut_pkg;\n")

f.close()

#plot waveform for reference:    
plt.plot(sine_array)
plt.ylabel('Sine waveform')
plt.show()

