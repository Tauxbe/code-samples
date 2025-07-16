using System;
using System.Collections.Generic;
using System.IO;

class Program
{
    static void Main(string[] args)
    {
        string filePath = args.Length > 0 ? args[0] : "flatfile_data.txt";
        if (!File.Exists(filePath))
        {
            Console.WriteLine($"File not found: {filePath}");
            return;
        }

        using (var reader = new StreamReader(filePath))
        {
            string headerLine = reader.ReadLine();
            if (headerLine == null)
            {
                Console.WriteLine("File is empty.");
                return;
            }
            var header = ParseLine(headerLine);
            int numColumns = header.Count;
            Console.WriteLine($"expecting: {numColumns} tokens");
            string line;
            int lineNum = 2;
            while ((line = reader.ReadLine()) != null)
            {
                var row = ParseLine(line);
                if (row.Count != numColumns)
                {
                    Console.WriteLine($"Warning: Line {lineNum} has {row.Count} tokens, expected {numColumns}.");
                }
                else
                {
                    Console.WriteLine($"Line {lineNum} is valid with {row.Count} tokens.");
                    // Process the valid row as needed
                }
                lineNum++;
            }
        }
    }

    // Parses a pipe-delimited line with quoted fields
    static List<string> ParseLine(string line)
    {
        var tokens = new List<string>();
        bool inQuotes = false;
        var current = new System.Text.StringBuilder();
        for (int i = 0; i < line.Length; i++)
        {
            char c = line[i];
            if (c == '"')
            {
                inQuotes = !inQuotes;
                current.Append(c);
            }
            else if (c == '|' && !inQuotes)
            {
                tokens.Add(TrimQuotes(current.ToString()));
                current.Clear();
            }
            else
            {
                current.Append(c);
            }
        }
        tokens.Add(TrimQuotes(current.ToString()));
        return tokens;
    }

    static string TrimQuotes(string s)
    {
        if (s.StartsWith("\"") && s.EndsWith("\""))
            return s.Substring(1, s.Length - 2);
        return s;
    }
}
