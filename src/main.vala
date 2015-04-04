namespace Emul8or
{
	int main(string[] args)
	{
		Application application = new Application(args);
		
		if (!application.close_immediately)
			application.run();
		
		return 0;
	}
}
