import math
import matplotlib.pyplot as plt

COUNTER_WIDTH_BITS = 8
WAVEFORM_AMPLITUDE_BITS = 24

angle_step_size = (2 * math.pi) / (2**COUNTER_WIDTH_BITS)
amplitude = 2 ** WAVEFORM_AMPLITUDE_BITS - 1

sine_array = []

#generate sinewave array:
for step in range(0, 2**COUNTER_WIDTH_BITS - 1):
    sine_array.append(round(amplitude / 2 * math.sin(angle_step_size * step) + amplitude / 2))

print('type t_sine_array is array (0 to %d) of natural;' % (2 ** COUNTER_WIDTH_BITS - 1))
print('constant sine_lut : t_sine_array := ')
for i in range(0, 2**COUNTER_WIDTH_BITS - 1):
    if (i == 0):
        print('(%d,' % (sine_array[i]))
    elif (i == 2**COUNTER_WIDTH_BITS - 1):
        print('%d);' % (sine_array[i]))
    else:
        print('%d,' % (sine_array[i]))
    
plt.plot(sine_array)
plt.ylabel('Sine waveform')
plt.show()

