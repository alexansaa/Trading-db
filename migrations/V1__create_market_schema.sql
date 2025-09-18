-- Create canonical schema for the Python layer
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'market')
    EXEC('CREATE SCHEMA market');
