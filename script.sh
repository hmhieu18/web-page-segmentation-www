Rscript C:/Users/minhh/OneDrive/Documents/web-page-segmentation-www/cikm20-wps/src/main/r/evaluate-segmentation_all_once.R   --algo-dir "C:/Users/minhh/Downloads/webbis_results/content/webis_results"   --algo-name "sam"   --ids-file C:/Users/minhh/OneDrive/Documents/web-page-segmentation-www/success_ids.json   --output-dir C:/Users/minhh/OneDrive/Documents/web-page-segmentation-www/eval   --ground-truth-dir C:/Users/minhh/Downloads/webis-webseg-20-selected

Rscript C:\Users\minhh\OneDrive\Documents\web-page-segmentation-www\cikm20-wps\src\main\r\flatten-segmentations.R --input C:\Users\minhh\Downloads\webbis_results\content\webis_results\000059.json --output 000059_flat.json

Rscript C:\Users\minhh\OneDrive\Documents\web-page-segmentation-www\cikm20-wps\src\main\r\evaluate-segmentation.R --algorithm 000059_flat.json --ground-truth C:\Users\minhh\Downloads\webis-webseg-20-selected\000059.json --output C:\Users\minhh\OneDrive\Documents\web-page-segmentation-www\eval\000059_flat.json --size-function pixel

Rscript C:/Users/minhh/OneDrive/Documents/web-page-segmentation-www/cikm20-wps/src/main/r/plot-segmentations.R --input C:/Users/minhh/Downloads/webbis_results/content/webis_results/000059_flat.json --screenshot C:/Users/minhh/Downloads/webis-webseg-20-selected/000059/screenshot.png --output abc.png --segmentations sam


Rscript C:\Users\minhh\OneDrive\Documents\web-page-segmentation-www\cikm20-wps\src\main\r\fit-segmentations-to-dom-nodes.R --input C:\Users\minhh\Downloads\webbis_results\content\webis_results\000059.json --output 000059_fitted.json --nodes C:/Users/minhh/Downloads/webis-webseg-20-selected/000059/nodes.csv

Rscript cikm20-wps/src/main/r/fit-segmentations-to-dom-nodes_all_once.R   --algo-dir C:\Users\minhh\Downloads\webbis_results\content\webis_results   --algo-name sam   --ids-file success_ids.json   --output-dir webis-webseg-20-fitted   --ground-truth-dir C:\Users\minhh\Downloads\webis-webseg-20-selected

Rscript cikm20-wps\src\main\r\flatten-segmentations_all_once.R   --algo-dir C:\Users\minhh\Downloads\webbis_results\content\webis_results   --algo-name sam   --ids-file success_ids.json   --output-dir webis-webseg-20-fitted
