from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import pandas as pd

def inicializar_navegador():
    options = webdriver.ChromeOptions()
    options.add_argument('--start-maximized')
    options.add_argument('--disable-extensions')
    options.add_argument("--incognito")
    driver = webdriver.Chrome(options=options)
    return driver







def getAuthors(query):
    driver = inicializar_navegador()
    driver.get("https://scholar.google.es/citations?view_op=search_authors&mauthors="+query+"&hl=es&oi=ao")
    try:
        authors_divs = driver.find_elements(By.CLASS_NAME, 'gsc_1usr')

        # Lista para almacenar los datos de cada autor
        authors_data = []

        # Extrae los datos de cada autor
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
        # Encuentra la tabla por su ID
    table = driver.find_element(By.ID, 'gsc_rsb_st')

    # Encuentra todas las filas del cuerpo de la tabla
    rows = table.find_elements(By.TAG_NAME, 'tr')

    # Lista para almacenar los datos de la tabla
    table_data = []

    # Itera sobre cada fila y extrae los datos
    for row in rows[1:]:  # Saltar la primera fila de encabezados
        cells = row.find_elements(By.TAG_NAME, 'td')
        if len(cells) >= 3:  # Asegúrate de que hay suficientes celdas en la fila
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


