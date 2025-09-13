# Morse Code Reader

A real-time Morse code decoder system built on ATmega128 microcontroller, designed to help people with speech disabilities communicate through Morse code input.

## 🎯 Project Overview

This project implements a portable Morse code reader that translates Morse code tapped by users into readable text displayed on an LCD screen. The system was developed as part of the MICRO-210 course at EPFL.

### Key Features

- **Real-time Morse code decoding** following international Morse code conventions
- **Adjustable input speed** (prescaler) for different user skill levels
- **LCD display** showing decoded text and system status
- **Message scrolling** for texts longer than 16 characters
- **Remote control integration** for menu navigation
- **3D-printed tactile interface** for comfortable Morse input

## 📋 Requirements

### Hardware
- ATmega128 microcontroller (STK-300 board)
- Hitachi HD44780U 2x16 LCD display
- SHARP GP2Y0A21 distance sensor
- Vivanco UR Z2 infrared remote control
- Angular encoder
- 3D-printed morse key/membrane

### Software
- Atmel Studio 7.0 or compatible AVR development environment
- AVRISP-U programmer or compatible

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Gautier9d/morse-code-reader.git
   cd morse-code-reader
   ```

2. **Hardware Setup**
   - Connect the LCD display to the LCD port on the STK-300
   - Connect the distance sensor to PORT F
   - Connect the encoder to PORT E
   - Connect the IR receiver module to PIN 7 of PORT E
   - Power the board with 230V AC through the appropriate adapter

3. **Compile and Upload**
   - Open the project in Atmel Studio 7.0
   - Navigate to the `src/` folder
   - Set `main.asm` as the entry file
   - Build the project (F7)
   - Upload to the ATmega128 using AVRISP-U

## 📖 Usage

### Controls

| Button/Input | Function |
|--------------|----------|
| **Channel Up** | Enter menu mode |
| **Channel Down** | Exit menu / Enter reading mode |
| **+** | Increase prescaler (slower morse speed) |
| **-** | Decrease prescaler (faster morse speed) |
| **Mute** | Clear displayed message |
| **Encoder (rotate)** | Scroll message left/right in menu |
| **Distance sensor** | Input Morse code (hand detection) |

### Morse Code Input

1. **Short signal (dot)**: Brief hand presence (1 time unit)
2. **Long signal (dash)**: Extended hand presence (3 time units)
3. **Between signals**: 1 time unit pause
4. **Between letters**: 3 time units pause  
5. **Between words**: 7 time units pause

### Display Information

**Menu Mode:**
```
presc: 4    s: 0
[Your message here]
```
- `presc`: Current prescaler value (1-7)
- `s`: Message scroll offset

**Reading Mode:**
```
d: 0    e: 7
[Decoded text appears here]
```
- `d`: Current dot count (debugging)
- `e`: Empty count (debugging)

## 📁 Project Structure

```
morse-code-reader/
├── src/                        # Source code files
│   ├── main.asm               # Main program logic and interrupt handlers
│   ├── definitions.asm        # ATmega128 register definitions
│   ├── macros.asm            # Reusable macro definitions
│   ├── encoder.asm           # Angular encoder driver
│   ├── lcd.asm               # LCD display driver
│   ├── printf.asm            # Formatted output for LCD
│   ├── remote.asm            # IR remote control decoder
│   ├── sharp.asm             # Distance sensor interface
│   ├── table.asm             # Morse code lookup table
│   ├── variables_control.asm # Variable initialization
│   └── variables_definition.asm # SRAM variable allocation
├── Report.pdf                 # Detailed project documentation
├── LICENSE                    # MIT License
└── README.md                  # This file
```

## 🏗️ Technical Details

### Memory Organization

The system uses SRAM addresses `0x0100` to `0x0170`:
- `0x0100-0x010F`: Control variables (flags, counters, pointers)
- `0x0110-0x12F`: Decoded message buffer (32 characters)
- `0x0130-0x016F`: Morse code lookup table (4x16 matrix)

### Decoding Algorithm

The decoder uses an efficient binary representation:
- Dots = 0, Dashes = 1
- Characters stored in 2D lookup table indexed by:
  - Row: Signal length (1-4 symbols)
  - Column: Binary representation of the pattern

Example: "C" (-.-.):
- Pattern: dash-dot-dash-dot
- Binary: 1010 = 10 decimal
- Length: 4 symbols
- Table position: Row 4, Column 10

### Interrupt System

- **INT7**: IR remote control commands (menu navigation)
- **Timer0 Overflow**: Morse code timing and decoding
- **ADC Complete**: Distance sensor readings

## ⚙️ Configuration

### Adjustable Parameters

In `src/main.asm`:
```assembly
.equ MENU_REFRESH_RATE_MS = 10  ; Menu update rate
.equ INIT_PRESCALER = 4         ; Default speed setting
.equ MIN_PRESCALER = 1           ; Fastest input speed
.equ MAX_PRESCALER = 7           ; Slowest input speed
```

### Timing Constants
```assembly
.equ NB_SHORT = 1       ; Dot duration
.equ NB_DASH = 3        ; Dash duration  
.equ NB_NEXT_LETTER = 3 ; Letter spacing
.equ NB_NEXT_WORD = 7   ; Word spacing
```

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| No display output | Check LCD connections and contrast adjustment |
| Remote not responding | Verify IR receiver connection on PORT E, PIN 7 |
| Incorrect decoding | Adjust prescaler to match your input speed |
| Message not scrolling | Ensure encoder is properly connected to PORT E |
| Distance sensor not detecting | Check SHARP sensor connection on PORT F |
| LEDs not indicating status | Verify PORT B connections and LED orientation |

## 📚 Documentation

- [Full Project Report](Report.pdf) - Comprehensive technical documentation with circuit diagrams and detailed explanations
- [ATmega128 Datasheet](https://www.microchip.com/wwwproducts/en/ATmega128)
- [HD44780U LCD Controller Datasheet](https://www.sparkfun.com/datasheets/LCD/HD44780.pdf)
- [International Morse Code Reference](https://en.wikipedia.org/wiki/Morse_code)

## 🎓 Academic Context

This project was developed as part of the **MICRO-210** course at EPFL (École Polytechnique Fédérale de Lausanne) during the Spring 2023 semester. The project demonstrates practical applications of:

- Embedded systems programming in assembly language
- Real-time signal processing
- Interrupt-driven programming
- Hardware interfacing (LCD, sensors, remote control)
- Assistive technology development

## 👥 Authors

- **Gautier DEMIERRE** - [GitHub](https://github.com/Gautier9d)
- **Romain COUYOUMTZELIS**

Course: MICRO-210 - Microcontrollers  
Institution: EPFL  
Semester: Spring 2023  
Group: 45

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Prof. A. Schmid** - Course professor and theoretical foundations
- **R. Holzer** - Laboratory supervisor and practical guidance
- **EPFL STI** - For providing development hardware and facilities
- Course teaching assistants for their support throughout the project

## 🚀 Future Improvements

- [ ] Add audio feedback for input confirmation
- [ ] Implement character deletion functionality
- [ ] Add support for numbers and punctuation marks
- [ ] Create a PC interface for message export via UART
- [ ] Develop adaptive speed detection algorithm
- [ ] Add multi-language Morse code support
- [ ] Implement message storage in EEPROM
- [ ] Add vibration feedback for tactile confirmation
- [ ] Design a more compact, portable version
- [ ] Create a smartphone app companion via Bluetooth

## 📞 Contact

For questions about this project, please open an issue on GitHub or consult the [project report](Report.pdf) for detailed technical information.

---

*This project demonstrates the practical application of embedded systems in assistive technology, providing a communication tool for individuals with speech disabilities through the timeless simplicity of Morse code.*
