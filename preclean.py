import pandas as pd

# Read the raw CSV
df = pd.read_csv(
    'seeds/olist_order_reviews_dataset.csv',
    on_bad_lines='skip'  # skip malformed rows
)

# Clean text fields that contain newlines
df['review_comment_title'] = df['review_comment_title'].astype(str).str.replace('\n', ' ').str.replace('\r', ' ')
df['review_comment_message'] = df['review_comment_message'].astype(str).str.replace('\n', ' ').str.replace('\r', ' ')

# Write back to CSV
df.to_csv('seeds/olist_order_reviews_dataset.csv', index=False)

print(f"Rows saved: {len(df)}")