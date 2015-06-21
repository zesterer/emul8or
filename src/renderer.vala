namespace Emul8or
{
	public class Renderer : Object
	{
		public Emulator emulator;
		
		unowned SDL.Screen screen;
		
		private int width = 64;
		private int height = 32;
		
		private float[,] glow_value;
		
		private int scale = 8;
		
		public Renderer(Emulator emulator, int scale)
		{
			stdout.printf("Starting renderer...\n");
			
			this.glow_value = new float[64, 32];
			
			this.emulator = emulator;
			this.scale = scale;
			
			SDL.init(SDL.InitFlag.VIDEO);
			this.screen = SDL.Screen.set_video_mode(this.width * this.scale, this.height * this.scale, 8, SDL.SurfaceFlag.HWSURFACE);
			SDL.WindowManager.set_caption("Emul8or 0.1", "");
		}
		
		public bool run()
		{
			bool should_quit = false;
			
			SDLGraphics.Rectangle.fill_color(this.screen, 0, 0, (int16)(this.width * this.scale), (int16)(this.height * this.scale), 0x000000FF);
			
			for (int x = 0; x < this.width; x ++)
			{
				for (int y = 0; y < this.height; y ++)
				{
					if (this.emulator.screen[x, y] == 1)
						this.glow_value[x, y] = 2.0f;
					else
						this.glow_value[x, y] = (float)Math.fmax(0.0f, this.glow_value[x, y] - 0.5f);
					
					uint8 glow = (uint8)Math.fmin(this.glow_value[x, y] * 256.0f, 255.0f);
					
					//if (glow < 225)
						//glow = 0;
					
					uint32 val = (glow << 8) + (glow << 16) + (glow << 24) + 255;
					
					SDLGraphics.Rectangle.fill_color(this.screen, (int16)(x * this.scale), (int16)(y * this.scale), (int16)((x + 1) * this.scale), (int16)((y + 1) * this.scale), (uint32)(val));
				}
			}
			
			this.screen.flip();
			
			SDL.Event event;
			while (SDL.Event.poll(out event) == 1)
			{
				if (event.type == SDL.EventType.QUIT)
					should_quit = true;
				
				if (event.type == SDL.EventType.KEYDOWN || event.type == SDL.EventType.KEYUP)
				{
					bool val = (event.type == SDL.EventType.KEYDOWN) ? true : false;
					
					switch (event.key.keysym.sym)
					{
						case (SDL.KeySymbol.ZERO):
							this.emulator.keys[0] = val;
							break;
						
						case (SDL.KeySymbol.ONE):
							this.emulator.keys[1] = val;
							break;
						
						case (SDL.KeySymbol.TWO):
							this.emulator.keys[2] = val;
							break;
						
						case (SDL.KeySymbol.THREE):
							this.emulator.keys[3] = val;
							break;
						
						case (SDL.KeySymbol.FOUR):
							this.emulator.keys[4] = val;
							break;
						
						case (SDL.KeySymbol.FIVE):
							this.emulator.keys[5] = val;
							break;
						
						case (SDL.KeySymbol.SIX):
							this.emulator.keys[6] = val;
							break;
						
						case (SDL.KeySymbol.SEVEN):
							this.emulator.keys[7] = val;
							break;
						
						case (SDL.KeySymbol.EIGHT):
							this.emulator.keys[8] = val;
							break;
						
						case (SDL.KeySymbol.NINE):
							this.emulator.keys[9] = val;
							break;
						
						case (SDL.KeySymbol.a):
							this.emulator.keys[10] = val;
							break;
						
						case (SDL.KeySymbol.b):
							this.emulator.keys[11] = val;
							break;
						
						case (SDL.KeySymbol.c):
							this.emulator.keys[12] = val;
							break;
						
						case (SDL.KeySymbol.d):
							this.emulator.keys[13] = val;
							break;
						
						case (SDL.KeySymbol.e):
							this.emulator.keys[14] = val;
							break;
						
						case (SDL.KeySymbol.f):
							this.emulator.keys[15] = val;
							break;
						
						default:
							break;
					}
				}
			}
			
			return should_quit;
		}
		
		public void checkKeys()
		{
			
		}
		
		public void quit()
		{
			stdout.printf("Quitting renderer...\n");
			
			SDL.quit();
		}
	}
}
