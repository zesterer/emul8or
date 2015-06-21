namespace Emul8or
{
	public class Emulator : Object
	{
		public bool is_loaded = false;
		
		//Registers
		public uint8[] registers = new uint8[0x010];
		
		public uint16 program_counter = 0x200;
		public uint16 address_register = 0x000;
		public Stack stack;
		
		//The keys
		public bool[] keys = new bool[16];
		
		//The screen
		public uint8[,] screen = new uint8[64, 32];
		
		//The clock
		public uint64 clock = 0;
		
		//Timer
		public uint8 delay_timer = 60;
		
		//Memory
		public uint8[] memory = new uint8[0x1000];
		
		//Font set
		public uint8[] font_set = {
		0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
		0x20, 0x60, 0x20, 0x20, 0x70, // 1
		0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
		0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
		0x90, 0x90, 0xF0, 0x10, 0x10, // 4
		0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
		0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
		0xF0, 0x10, 0x20, 0x40, 0x40, // 7
		0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
		0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
		0xF0, 0x90, 0xF0, 0x90, 0x90, // A
		0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
		0xF0, 0x80, 0x80, 0x80, 0xF0, // C
		0xE0, 0x90, 0x90, 0x90, 0xE0, // D
		0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
		0xF0, 0x80, 0xF0, 0x80, 0x80  // F
		};
		
		public Emulator()
		{
			stdout.printf("Starting emulator...\n");
			
			this.stack.reset();
			
			//Copy font to memory
			for (uint16 count = 0; count < this.font_set.length; count ++)
				this.memory[count] = this.font_set[count];
		}
		
		public bool run()
		{
			if (!this.is_loaded)
			{
				if (this.load())
					stdout.printf("Loaded ROM into memory.\n");
				else
					stdout.printf("Failed to load ROM into memory.\n");
			}
			
			while (true)
			{
				uint16 opcode = this.getOpcode();
				
				switch(opcode & 0xF000)
				{
					case (0x0000):
						this.op0(opcode);
						break;
					
					case (0x1000):
						this.op1(opcode);
						break;
					
					case (0x2000):
						this.op2(opcode);
						break;
					
					case (0x3000):
						this.op3(opcode);
						break;
					
					case (0x4000):
						this.op4(opcode);
						break;
					
					case (0x5000):
						this.op5(opcode);
						break;
					
					case (0x6000):
						//stdout.printf("opcode: %X\n", opcode);
						this.op6(opcode);
						break;
					
					case (0x7000):
						this.op7(opcode);
						break;
					
					case (0x8000):
						this.op8(opcode);
						break;
					
					case (0x9000):
						this.op9(opcode);
						break;
					
					case (0xA000):
						this.opA(opcode);
						break;
					
					case (0xB000):
						this.opB(opcode);
						break;
					
					case (0xC000):
						this.opC(opcode);
						break;
					
					case (0xD000):
						this.opD(opcode);
						break;
					
					case (0xE000):
						this.opE(opcode);
						break;
					
					case (0xF000):
						this.opF(opcode);
						break;
				}
				
				this.program_counter += 2;
				
				this.clock ++;
				
				if (this.clock % 20 == 0)
				{
					if (this.delay_timer <= 0)
						this.delay_timer = 60;
					else
						this.delay_timer -= 1;
					
					break;
				}
			}
			
			return false;
		}
		
		public void op0(uint16 opcode)
		{
			switch(opcode)
			{
				case (0x00E0):
					this.op00E0(opcode);
					break;
				
				case(0x00EE):
					this.op00EE(opcode);
					break;
				
				default:
					this.op0NNN(opcode);
					break;
			}
		}
		
		public void op00E0(uint16 opcode)
		{
			for (uint8 xx = 0; xx < this.screen.length[0]; xx ++)
			{
				for (uint8 yy = 0; yy < this.screen.length[1]; yy ++)
				{
					this.screen[xx, yy] &= 0;
				}
			}
		}
		
		public void op00EE(uint16 opcode)
		{
			uint16 target = this.stack.pop();
			//stdout.printf("Leaving procedure, returning to %X\n", target);
			this.program_counter = target;
		}
		
		public void op0NNN(uint16 opcode)
		{
			//Calls RCA 1802 program at address NNN.
			//this.program_counter = opcode & 0x0FFF - 2;
		}
		
		public void op1(uint16 opcode)
		{
			this.program_counter = (opcode & 0x0FFF) - 2;
			//stdout.printf("Jumped to %X\n", opcode & 0x0FFF);
		}
		
		public void op2(uint16 opcode)
		{
			this.stack.push(this.program_counter);
			this.program_counter = (opcode & 0x0FFF) - 2;
			//stdout.printf("Subroutine at %X\n", opcode & 0x0FFF);
		}
		
		public void op3(uint16 opcode)
		{
			if (this.registers[(opcode & 0x0F00) >> 8] == (opcode & 0x00FF))
			{
				//stdout.printf("Instruction skipped.\n");
				this.program_counter += 2;
			}
		}
		
		public void op4(uint16 opcode)
		{
			if (this.registers[(opcode & 0x0F00) >> 8] != (opcode & 0x00FF))
				this.program_counter += 2;
		}
		
		public void op5(uint16 opcode)
		{
			if (this.registers[(opcode & 0x0F00) >> 8] == this.registers[(opcode & 0x00F0) >> 4])
				this.program_counter += 2;
		}
		
		public void op6(uint16 opcode)
		{
			//stdout.printf("Set V%X to %X\n", (opcode & 0x0F00) >> 8, (opcode & 0x00FF));
			this.registers[(opcode & 0x0F00) >> 8] = (uint8)(opcode & 0x00FF);
		}
		
		public void op7(uint16 opcode)
		{
			this.registers[(opcode & 0x0F00) >> 8] += (uint8)(opcode & 0x00FF);
			//stdout.printf("Adding %X to V%X (it's now %X) \n", (opcode & 0x00FF), (opcode & 0x0F00) >> 8, this.registers[(opcode & 0x0F00) >> 8]);
		}
		
		public void op8(uint16 opcode)
		{
			switch(opcode & 0x000F)
			{
				case (0x0000):
					this.op8XY0(opcode);
					break;
				
				case (0x0001):
					this.op8XY1(opcode);
					break;
				
				case (0x0002):
					this.op8XY2(opcode);
					break;
				
				case (0x0003):
					this.op8XY3(opcode);
					break;
				
				case (0x0004):
					this.op8XY4(opcode);
					break;
				
				case (0x0005):
					this.op8XY5(opcode);
					break;
				
				case (0x0006):
					this.op8XY6(opcode);
					break;
				
				case (0x0007):
					this.op8XY7(opcode);
					break;
				
				case (0x000E):
					this.op8XYE(opcode);
					break;
			}
		}
		
		public void op8XY0(uint16 opcode)
		{
			this.registers[(opcode & 0x0F00) >> 8] = this.registers[(opcode & 0x00F0) >> 4];
		}
		
		public void op8XY1(uint16 opcode)
		{
			this.registers[(opcode & 0x0F00) >> 8] = this.registers[(opcode & 0x0F00) >> 8] | this.registers[(opcode & 0x00F0) >> 4];
		}
		
		public void op8XY2(uint16 opcode)
		{
			this.registers[(opcode & 0x0F00) >> 8] = this.registers[(opcode & 0x0F00) >> 8] & this.registers[(opcode & 0x00F0) >> 4];
		}
		
		public void op8XY3(uint16 opcode)
		{
			this.registers[(opcode & 0x0F00) >> 8] = this.registers[(opcode & 0x0F00) >> 8] ^ this.registers[(opcode & 0x00F0) >> 4];
		}
		
		public void op8XY4(uint16 opcode)
		{
			if ((int16)this.registers[(opcode & 0x0F00) >> 8] + (int16)this.registers[(opcode & 0x00F0) >> 4] > 0xFF)
				this.registers[0xF] = 0x01;
			else
				this.registers[0xF] = 0x00;
			
			this.registers[(opcode & 0x0F00) >> 8] += this.registers[(opcode & 0x00F0) >> 4];
		}
		
		public void op8XY5(uint16 opcode)
		{
			if ((int16)this.registers[(opcode & 0x0F00) >> 8] - (int16)this.registers[(opcode & 0x00F0) >> 4] < 0x00)
				this.registers[0xF] = 0x00;
			else
				this.registers[0xF] = 0x01;
			
			this.registers[(opcode & 0x0F00) >> 8] -= this.registers[(opcode & 0x00F0) >> 4];
		}
		
		public void op8XY6(uint16 opcode)
		{
			this.registers[0xF] = this.registers[(opcode & 0x0F00) >> 8] & 0x01;
			
			this.registers[(opcode & 0x0F00) >> 8] >>= 1;
		}
		
		public void op8XY7(uint16 opcode)
		{
			if ((int16)this.registers[(opcode & 0x00F0) >> 4] - (int16)this.registers[(opcode & 0x0F00) >> 8] < 0x00)
				this.registers[0xF] = 0x00;
			else
				this.registers[0xF] = 0x01;
			
			this.registers[(opcode & 0x0F00) >> 8] -= this.registers[(opcode & 0x00F0) >> 4] - this.registers[(opcode & 0x0F00) >> 8];
		}
		
		public void op8XYE(uint16 opcode)
		{
			this.registers[0xF] = (this.registers[(opcode & 0x0F00) >> 8] & 0x80) >> 7;
			
			this.registers[(opcode & 0x0F00) >> 8] <<= 1;
		}
		
		public void op9(uint16 opcode)
		{
			if (this.registers[(opcode & 0x0F00) >> 8] != this.registers[(opcode & 0x00F0) >> 4])
				this.program_counter += 2;
		}
		
		public void opA(uint16 opcode)
		{
			this.address_register = opcode & 0x0FFF;
			//stdout.printf("Jumped to %X\n", opcode & 0x0FFF);
		}
		
		public void opB(uint16 opcode)
		{
			this.program_counter = opcode & 0x0FFF + this.registers[0];
		}
		
		public void opC(uint16 opcode)
		{
			this.registers[(opcode & 0x0F00) >> 8] = (uint8)Random.next_int() & (opcode & 0x00FF);
		}
		
		public void opD(uint16 opcode)
		{
			//stdout.printf("Drawing at x=%X, y=%X with height %X.\n", this.registers[(opcode & 0x0F00) >> 8], this.registers[(opcode & 0x00F0) >> 4], opcode & 0x000F);
			uint8 n = (uint8)(opcode & 0x000F);
			
			uint8 dx = this.registers[(opcode & 0x0F00) >> 8];
			uint8 dy = this.registers[(opcode & 0x00F0) >> 4];
			
			this.registers[0xF] = 0;
			
			for (int8 y = 0; y < n; y ++)
			{
				for (int8 x = 0; x < 8; x ++)
				{
					bool flip = (this.memory[this.address_register + y] & (0x80 >> x)) != 0;
					
					if (flip)
					{
						if (this.screen[(dx + x) % 64, (dy + y) % 32] == 1)
						{
							this.registers[15] = 1;
						}
					
						if (this.screen[(dx + x) % 64, (dy + y) % 32] == 1)
							this.screen[(dx + x) % 64, (dy + y) % 32] = 0;
						else
							this.screen[(dx + x) % 64, (dy + y) % 32] = 1;
					}
				}
			}
		}
		
		public void opE(uint16 opcode)
		{
			switch (opcode & 0x00FF)
			{
				case (0x009E):
					this.opEX9E(opcode);
					break;
				
				case (0x00A1):
					this.opEXA1(opcode);
					break;
			}
		}
		
		public void opEX9E(uint16 opcode)
		{
			if (this.keys[(opcode & 0x0F00) >> 8] == true)
				this.program_counter += 2;
		}
		
		public void opEXA1(uint16 opcode)
		{
			if (this.keys[(opcode & 0x0F00) >> 8] == false)
				this.program_counter += 2;
		}
		
		public void opF(uint16 opcode)
		{
			switch (opcode & 0x00FF)
			{
				case (0x0007):
					this.opFX07(opcode);
					break;
				
				case (0x000A):
					this.opFX0A(opcode);
					break;
				
				case (0x0015):
					this.opFX15(opcode);
					break;
				
				case (0x0018):
					this.opFX18(opcode);
					break;
				
				case (0x001E):
					this.opFX1E(opcode);
					break;
				
				case (0x0029):
					this.opFX29(opcode);
					break;
				
				case (0x0033):
					this.opFX33(opcode);
					break;
				
				case (0x0055):
					this.opFX55(opcode);
					break;
				
				case (0x0065):
					this.opFX65(opcode);
					break;
			}
		}
		
		public void opFX07(uint16 opcode)
		{
			this.registers[(opcode & 0x0F00) >> 8] = this.delay_timer;
		}
		
		public void opFX0A(uint16 opcode)
		{
			//TODO Await key press
			
			uint8 count = 0;
			
			for (count = 0; count < 16; count ++)
			{
				if (this.keys[count])
				{
					this.registers[(opcode & 0x0F00) >> 8] = count;
					break;
				}
			}
			
			if (count == 16)
				this.program_counter -= 2;
		}
		
		public void opFX15(uint16 opcode)
		{
			this.delay_timer = this.registers[(opcode & 0x0F00) >> 8];
		}
		
		public void opFX18(uint16 opcode)
		{
			//SOUND TIMER STUFF TODO
		}
		
		public void opFX1E(uint16 opcode)
		{
			this.address_register += this.registers[(opcode & 0x0F00) >> 8];
		}
		
		public void opFX29(uint16 opcode)
		{
			//FONT STUFF TODO
			//stdout.printf("A character!\n");
			this.address_register = (this.registers[(opcode & 0x0F00) >> 8]) * 5;
		}
		
		public void opFX33(uint16 opcode)
		{
			uint8 regx = (opcode & 0x0F00) >> 8;

			uint8 val = this.registers[regx];

			uint8 hundreds = val / 100;
			uint8 tens = (val / 10) % 10;
			uint8 units = val % 10;

			this.memory[this.address_register] = hundreds;
			this.memory[this.address_register + 1] = tens;
			this.memory[this.address_register + 2] = units;
		}
		
		public void opFX55(uint16 opcode)
		{
			uint8 regx = (opcode & 0x0F00) >> 8;

			for (int count = 0; count <= regx; count ++)
			{
				this.memory[this.address_register + count] = this.registers[count];
			}

			this.address_register += regx + 1;
		}
		
		public void opFX65(uint16 opcode)
		{
			uint8 regx = (opcode & 0x0F00) >> 8;

			for (int count = 0; count <= regx; count ++)
			{
				this.registers[count] = this.memory[this.address_register + count];
			}

			this.address_register += regx + 1;
		}
		
		public uint16 getOpcode()
		{
			uint16 part0 = (uint16)this.memory[this.program_counter] * 256;
			uint16 part1 = ((uint16)this.memory[this.program_counter + 1]) & 0x00FF;
			
			return part0 + part1;
		}
		
		public bool load(string filename = "tetris.c8")
		{
			uint8[] data;
			
			//Although technically it's not loaded, it's safe to assume that
			//if there is an error now, there will be the same error every time
			//is attempts to load anything...
			this.is_loaded = true;
			
			//Attempt to load the data
			try
			{
				if (!FileUtils.get_data(filename, out data))
					return false;
			}
			catch (Error error)
			{
				return false;
			}
			
			for (uint16 count = 0; count < data.length; count ++)
				this.memory[count + 0x200] = data[count];
			
			for (int16 count = 0; count < data.length; count += 2)
			{
				stdout.printf("%X:	", count + 0x200);
				
				if (data[count] <= 0xF)
					stdout.printf("0%X", data[count]);
				else
					stdout.printf("%X", data[count]);
				
				stdout.printf("-");
				
				if (data[count + 1] <= 0xF)
					stdout.printf("0%X", data[count + 1]);
				else
					stdout.printf("%X", data[count + 1]);
				
				stdout.printf("\n");
			}
			
			return true;
		}
		
		public void quit()
		{
			stdout.printf("Quitting emulator...\n");
		}
	}
	
	public struct Stack
	{
		public int16 current;
		public uint16[] stack;
		
		public void reset()
		{
			this.current = -1;
			this.stack = new uint16[0x040];
		}
		
		public void push(uint16 n)
		{
			this.current = this.current > 63 ? 63 : this.current + 1;
			this.stack[this.current] = n;
		}
		
		public uint16 pop()
		{
			this.current = this.current < 0 ? -1 : this.current - 1;
			return this.stack[this.current + 1];
		}
	}
}
