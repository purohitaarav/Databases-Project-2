# ilab_script.py

import sys
import psycopg2
import pandas as pd

def main():
    # Connect to your database
    conn = psycopg2.connect(
        host="postgres.cs.rutgers.edu",
        database="group30",
        user="lh715",  # your NetID
        password="1Njusalisa."  # optional: you might set this up with getpass instead
    )
    cur = conn.cursor()
    
    # Check if query is passed as an argument
    if len(sys.argv) > 1:
        query = sys.argv[1]
    else:
        print("No SQL query provided as argument. Please type your SQL query:")
        lines = []
        while True:
            line = input()
            lines.append(line)
            if ';' in line:
                break
        query = '\n'.join(lines)
    
    # Run the query
    try:
        cur.execute(query)
        rows = cur.fetchall()
        colnames = [desc[0] for desc in cur.description]
        
        # Format nicely with pandas
        df = pd.DataFrame(rows, columns=colnames)
        print(df.to_string(index=False))
        
    except Exception as e:
        print(f"An error occurred: {e}")
    
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    main()
