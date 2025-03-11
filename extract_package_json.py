import os

# Output file to store all package.json content
output_file = "all_package_json.txt"

with open(output_file, "w", encoding="utf-8") as out_f:
    # Walk through the project directory recursively
    for root, dirs, files in os.walk("."):
        for file in files:
            if file == "package.json":
                file_path = os.path.join(root, file)
                out_f.write(f"----- {file_path} -----\n\n")
                try:
                    with open(file_path, "r", encoding="utf-8") as in_f:
                        out_f.write(in_f.read())
                        out_f.write("\n\n")
                except Exception as e:
                    out_f.write(f"Error reading file: {str(e)}\n\n")

print(f"Extract created: {output_file}")