from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

import time
import pandas as pd
import os


def inicializar_navegador():
    options = webdriver.ChromeOptions()
    options.add_argument('--start-maximized')
    options.add_argument('--disable-extensions')
    options.add_argument("--incognito")
    options.add_argument("--headless")  
    options.add_argument("--disable-gpu")  
    options.add_argument("--no-sandbox")  
    options.add_argument("--disable-dev-shm-usage") 
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    return driver



def getAuthors(query):
    driver = inicializar_navegador()
    driver.get("https://scholar.google.es/citations?view_op=search_authors&mauthors="+query+"&hl=es&oi=ao")
    try:
        authors_divs = driver.find_elements(By.CLASS_NAME, 'gsc_1usr')

        authors_data = []

        for author_div in authors_divs:
            href = author_div.find_element(By.CLASS_NAME, 'gs_ai_pho').get_attribute('href')
            identifier = href.split('user=')[1]
            name = author_div.find_element(By.CLASS_NAME, 'gs_ai_name').text.strip()
            affiliation = author_div.find_element(By.CLASS_NAME, 'gs_ai_aff').text.strip()
            email = author_div.find_element(By.CLASS_NAME, 'gs_ai_eml').text.strip()
            cited_by = author_div.find_element(By.CLASS_NAME, 'gs_ai_cby').text.strip().replace('Citado por ', '')
            interests_elements = author_div.find_elements(By.CLASS_NAME, 'gs_ai_one_int')
            interests = ', '.join([element.text.strip() for element in interests_elements])
            
            authors_data.append({
                'ID': identifier,
                'Name': name,
                'Affiliation': affiliation,
                'Cited by': cited_by,
                'Interests': interests
            })
        driver.quit()
        if len(authors_data)>0:
            return pd.DataFrame(authors_data)
        else:
            return pd.DataFrame({'error': [True]})

    except Exception as e:
        print(f"Error al extraer datos de un autor: {e}")
        driver.quit()
        return pd.DataFrame({'error': [True]})



    


def getMetricsAuthor(id):
    driver=inicializar_navegador()
    driver.get("https://scholar.google.es/citations?hl=es&user="+id)
    table = driver.find_element(By.ID, 'gsc_rsb_st')

    rows = table.find_elements(By.TAG_NAME, 'tr')

    table_data = []

    for row in rows[1:]:  
        cells = row.find_elements(By.TAG_NAME, 'td')
        if len(cells) >= 3:  
            metric = cells[0].text.strip()
            total = cells[1].text.strip()
            since_2019 = cells[2].text.strip()
            
            table_data.append({
                'Métrica': metric,
                'Total': total,
                'Desde 2019': since_2019
            })
            
    driver.quit()
    
    return pd.DataFrame(table_data)


