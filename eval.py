import os

GROUND_TRUTH_DIR = 'C:/Users/minhh/Downloads/webis-webseg-20-selected'
EVAL_DIR = 'SAM_results'

def evaluate_file_id(id, dataset_path, size_functions, algorithm_file, algorithm_name):
    # cikm20-web-page-segmentation-revisited-evaluation-framework-and-dataset %
    # Rscript src/main/r/evaluate-segmentation.R
    # --algorithm annotations.json
    # --algorithm-segmentation my_algorithm
    # --ground-truth ground-truth.json
    # --size-function pixels
    # --output 0.csv
    
    r = r"C:\Program Files\R\R-4.4.1\bin\Rscript.exe"
    script = "cikm20-wps/src/main/r/evaluate-segmentation.R"
    
    algorithm_file = os.path.join("webis_results", f"{id}.json")
    ground_truth_file = os.path.join(GROUND_TRUTH_DIR, id, "ground-truth.json")
    output_file = os.path.join(EVAL_DIR, f"{id}.csv")    
    
    cmd = [
        f'"{r}"', script,
        "--algorithm", algorithm_file,
        "--algorithm-segmentation", algorithm_name,
        "--ground-truth", ground_truth_file,
        "--size-function", "pixels",
        "--output", output_file
    ]
    with open("command.txt", "w") as f:
        f.write(" ".join(cmd))
    os.system(" ".join(cmd))
    print(f"Done evaluating {id}")

def main():
    if not os.path.exists(EVAL_DIR):
        os.makedirs(EVAL_DIR)
    
    # load all the json files in webis_results
    for file in os.listdir("webis_results"):
        if file.endswith('.json'):
            id = file.split('.')[0]
            evaluate_file_id(id, GROUND_TRUTH_DIR, "pixels", file, "sam")
            input("Press Enter to continue...")


if __name__ == "__main__":
    main()


# Rscript C:\Users\minhh\OneDrive\Documents\web-page-segmentation-www\cikm20-wps\src\main\r\evaluate-segmentation_all_once.R --algo-dir "C:\Users\minhh\OneDrive\Documents\web-page-segmentation-www\webis_results" --algo-name "sam" --ids-file C:\Users\minhh\OneDrive\Documents\web-page-segmentation-www\ids.json --output-dir C:\Users\minhh\OneDrive\Documents\web-page-segmentation-www\SAM_results --ground-truth-dir C:\Users\minhh\Downloads\webis-webseg-20-selected