import os
import pandas as pd
import urllib
from unidecode import unidecode
import numpy as np
from elasticsearch.helpers import bulk, parallel_bulk
from collections import deque
import json
import time
import rapidfuzz

openfoodcols = ['product_name', 'energy_100g', 'nutriscore_score']




def import_openfood(from_latest = False,cols=openfoodcols, nrows = None):
    """
    Import and clean openfood data from https://fr.openfoodfacts.org/data 
    see https://world.openfoodfacts.org/terms-of-use 
    :param cols: A list of columns that is passed to pandas.read_csv to subset
      the file and speedup import. Default to None which means all columns
      are imported
    :return: A pandas.DataFrame
    """
    
    if os.path.isfile("openfood.csv") is False:
            urllib.request.urlretrieve("https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv", "openfood.csv")
        
    data = pd.read_csv(filepath_or_buffer='openfood.csv', 
                       delimiter="\t", 
                       usecols=cols, 
                       nrows = nrows, 
                       encoding = 'utf-8')
    data = data.dropna()
    return data
    

def import_ciqual():
    path = 'https://ciqual.anses.fr/cms/sites/default/files/inline-files/Table%20Ciqual%202020_FR_2020%2007%2007.xls'
    
    if os.path.isfile("ciqual.csv") is False:
            ciqual = pd.read_excel(path, usecols = ['alim_nom_fr', 'Energie, Règlement UE N° 1169/2011 (kcal/100 g)'])
            ciqual = ciqual[ciqual['Energie, Règlement UE N° 1169/2011 (kcal/100 g)']!='-']
            ciqual = ciqual.dropna()
    else:
        ciqual = pd.read_csv('ciqual.csv')
        
    return ciqual

def remove_accent(s):
    s = unidecode(s)
    return(s)




def clean_libelle(data, yvar = 'product_name', outvar = 'libel_clean',
                 replace_regex = {r'[^a-zA-Z]': ''}, stopWords = ['CRUE?S?']):
    
    data = data.copy()
    data[outvar] = data[yvar]  
    data[outvar] = data[outvar].astype(str).apply(lambda x: remove_accent(x))
    data[outvar] = data[outvar].str.upper()
    data[outvar] = data[outvar].str.replace(
            '|'.join([r'\b{}\b'.format(w) for w in stopWords]),
            "", regex = True
        )
    if replace_regex is not None:
        data.replace({outvar: replace_regex}, regex=True, inplace=True)
        data.replace({outvar: {r'([ ]{2,})': ' '} }, regex=True, inplace=True)  # Suppression des espaces multiples
    
    return data


def match_product(liste_produits, dataset_comparaison, yvar_comparaison = "alim_nom_fr"):
  start_time = time.time()
  out = [rapidfuzz.process.extract(c, dataset_comparaison[yvar_comparaison].tolist(), scorer=rapidfuzz.fuzz.token_sort_ratio, limit = 1) for c in liste_produits]
  out = [item for sublist in out for item in sublist]
  dist_leven = pd.DataFrame([c for c in out], columns = ['best_match', 'distance', 'index_ciqual'])
  dist_leven['produit'] = liste_produits
  print(f"Temps d'exécution total : {(time.time() - start_time):.2f} secondes ---")
  return dist_leven




def gen_dict_from_pandas(index_name, df):
    '''
    Lit un dataframe pandas Open Food Facts, renvoi un itérable = dictionnaire des données à indexer, sous l'index fourni
    '''
    for i, row in df.iterrows():
        header= {"_op_type": "index","_index": index_name,"_id": i}
        yield {**header,**row}
        
        
def index_elastic(es, index_name: str, setting_file: str, df = pd.DataFrame):
    '''
    Indexe OpenFoodFact dans index_name, à partir du data.frame df, en suivant les instructions d'indexation fournies dans le .json setting_file
    '''
    if es.indices.exists(index_name):
        es.indices.delete(index=index_name)
        
    with open(setting_file) as f:
        mapping = json.load(f)
    
    es.indices.create(index = index_name, body = mapping)
    
    start_time = time.time()
        
    deque(parallel_bulk(client=es, actions=gen_dict_from_pandas(index_name, df), chunk_size = 2000, thread_count = 4))
    
    print(f"Temps d'exécution total : {(time.time() - start_time):.2f} secondes ---")
