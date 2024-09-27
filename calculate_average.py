import os 
import pandas as pd
eval_dir = 'C:/Users/minhh/Downloads/evaluation-results-834/content/drive/MyDrive/kat-backup/evaluation-results'
eval_files = sorted([file for file in os.listdir(eval_dir) if file.endswith('.csv')])

df = pd.DataFrame()
for f in eval_files:
    temp_df = pd.read_csv(os.path.join(eval_dir, f))
    temp_df['id'] = f.split('.')[0]
    df = pd.concat([df, temp_df])
        
# group by size.function
# calculate average of bcubed.precision, bcubed.recall, bcubed.f1
groups = df.groupby('size.function')
results = dict()

for name, group in groups:
    results[name] = {
        'bcubed.precision': round(group['bcubed.precision'].mean(), 2),
        'bcubed.recall': round(group['bcubed.recall'].mean(), 2),
        'bcubed.f1': round(group['bcubed.f1'].mean(), 2)
    }
print(results)

with pd.ExcelWriter('evaluation_results.xlsx') as writer:
    # write a sheet for each size.function
    for name, group in groups:
        group.to_excel(writer, sheet_name=name, index=False)
    # write a sheet for the average
    pd.DataFrame(results).to_excel(writer, sheet_name='average')