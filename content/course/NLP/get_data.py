import pandas as pd

def create_train_dataframes():

  url='https://github.com/GU4243-ADS/spring2018-project1-ginnyqg/raw/master/data/spooky.csv'
  train = pd.read_csv(url, encoding='latin-1')
  train.columns = train.columns.str.capitalize()
  train['ID'] = train['Id'].str.replace("id","")
  train = train.set_index('Id')
  
  return train
