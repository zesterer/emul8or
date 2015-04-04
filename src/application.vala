namespace Emul8or
{
	public class Application : Object
	{
		public Emulator emulator;
		public Renderer renderer;
		
		public bool close_immediately = false;
		
		public Application(string[] args)
		{	
			int scale = 1;
			string? rom = null;
			
			for (int count = 0; count < args.length; count ++)
			{
				switch(args[count])
				{
					case ("-s"):
						count ++;
						scale = int.parse(args[count]);
						break;
					
					case ("--scale"):
						count ++;
						scale = int.parse(args[count]);
						break;
					
					case ("-h"):
						this.showHelp();
						this.close_immediately = true;
						break;
					
					case ("--help"):
						this.showHelp();
						this.close_immediately = true;
						break;
					
					default:
						rom = args[count];
						break;
				}
			}
			
			if (args.length <= 1)
			{
				this.showHelp();
				this.close_immediately = true;
			}
			
			if (!close_immediately)
			{
				stdout.printf("Starting application...\n");
				this.emulator = new Emulator();
				this.renderer = new Renderer(this.emulator, scale);
			}
			
			//Load something
			if (rom != null && !close_immediately)
				this.emulator.load(rom);
		}
		
		public void run()
		{
			stdout.printf("Running application...\n");
			
			bool should_quit = false;
			
			while (!should_quit)
			{
				should_quit |= this.emulator.run();
				should_quit |= this.renderer.run();
				
				//Pause for 1/50 seconds
				Thread.usleep(20000);
			}
			
			this.emulator.quit();
			this.renderer.quit();
		}
		
		public void showHelp()
		{
			stdout.printf("Usage: emul8or [OPTION]... [FILE]...\n");
			stdout.printf("Emulate a chip8 and play a ROM file.\n\n");
			stdout.printf("Mandatory arguments to long options are mandatory for short options too.\n");
			stdout.printf("  -s, --scale                scale the UI this number of times\n");
			stdout.printf("  -h, --help                 display this help and exit\n");
		}
	}
}
