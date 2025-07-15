import os
import json
import requests
from tqdm import tqdm

API_URL     = 'https://world.openbeautyfacts.org/api/v2/search'
CATEGORY    = 'hair care products'
PAGE_SIZE   = 100
TOTAL_ITEMS = 1000
OUTPUT_FILE = r'C:\Users\vitor\Documents\HairSense\database\hair_products.json'

FIELDS      = 'code,product_name,image_front_url,ingredients_text'

def fetch_page(page: int, page_size: int):
    params = {
        'tagtype_0':       'categories',
        'tag_contains_0':  'contains',
        'tag_0':           CATEGORY,
        'page':            page,
        'page_size':       page_size,
        'fields':          FIELDS,
    }
    resp = requests.get(API_URL, params=params, timeout=10)
    resp.raise_for_status()
    return resp.json().get('products', [])

def is_complete(raw: dict) -> bool:
    # Verifica se todos os campos existem e não são strings vazias
    return all([
        raw.get('code'),
        raw.get('product_name', '').strip(),
        raw.get('image_front_url', '').strip(),
        raw.get('ingredients_text', '').strip(),
    ])

def extract_fields(raw: dict) -> dict:
    return {
        'code':             raw['code'],
        'name':             raw['product_name'].strip(),
        'image_url':        raw['image_front_url'].strip(),
        'ingredients_text': raw['ingredients_text'].strip(),
    }

def main():
    print('Diretório atual:', os.getcwd())
    all_products = []
    page = 1

    # Continua puxando páginas até atingir TOTAL_ITEMS ou zerar resultados
    with tqdm(total=TOTAL_ITEMS, desc='Coletando produtos') as pbar:
        while len(all_products) < TOTAL_ITEMS:
            products = fetch_page(page, PAGE_SIZE)
            if not products:
                print(f'Não há mais produtos na página {page}.')
                break

            for raw in products:
                if is_complete(raw):
                    all_products.append(extract_fields(raw))
                    pbar.update(1)
                    if len(all_products) >= TOTAL_ITEMS:
                        break

            page += 1

    # Limita exatamente a TOTAL_ITEMS (caso tenha passado um pouco)
    all_products = all_products[:TOTAL_ITEMS]

    # Grava JSON formatado
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(all_products, f, ensure_ascii=False, indent=2)

    print(f'\nGerados {len(all_products)} produtos completos em {OUTPUT_FILE}')

if __name__ == '__main__':
    main()