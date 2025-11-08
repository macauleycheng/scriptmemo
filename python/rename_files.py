import os

def removeSubStr(location: str, substr: str):
    contents = os.listdir(location)
    for item in contents:
        if not os.path.isfile(location + "\\" + item):
            removeSubStr(location+"\\"+ item, substr)
            continue

        if substr not in item:
            continue
        
        new_file_name = item.replace(substr, "")
        try:
            os.rename(location + "\\" + item, location + "\\" + new_file_name)
            print(new_file_name)
        except:
            print("can't rename " + item)
        
if __name__ == "__main__":
    directory_path = r"\\family_68_2\tmp\bigtorrent\LUXU"  # Replace with your desired directory
    removeSubStr(directory_path, "_result")
