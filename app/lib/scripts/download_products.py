import os
import json
import time
import requests
from tqdm import tqdm

# Configurações gerais
API_URL        = 'https://world.openbeautyfacts.org/api/v2/search'
PAGE_SIZE      = 100
PARTIAL_FILE   = r'C:\Users\vitor\Documents\HairSense\database\hair_products_progress.json'
FIELDS         = 'code,product_name,image_front_url,ingredients_text,categories_tags'

# Verifica se o produto tem os campos obrigatórios
def is_complete(prod):
    return all([
        prod.get('code'),
        prod.get('product_name', '').strip(),
        prod.get('image_front_url', '').strip(),
        prod.get('ingredients_text', '').strip(),
        isinstance(prod.get('categories_tags'), list),
    ])

# Aceita qualquer tag que termine com :hair (de qualquer idioma)
def has_hair_tag(prod):
    return any(tag.lower().endswith('en:hair') for tag in prod.get('categories_tags', []))

# Extrai apenas os campos desejados
def extract(prod):
    return {
        'code':             prod['code'],
        'name':             prod['product_name'].strip(),
        'image_url':        prod['image_front_url'].strip(),
        'ingredients_text': prod['ingredients_text'].strip(),
    }

# Carrega progresso anterior (se existir)
def load_partial():
    if os.path.exists(PARTIAL_FILE):
        with open(PARTIAL_FILE, encoding='utf-8') as f:
            saved = json.load(f)
        products   = saved.get('products', [])
        seen_codes = set(p['code'] for p in products)
        last_page  = saved.get('last_page', 1)
        return products, seen_codes, last_page
    return [], set(), 1

# Salva progresso atual
def save_partial(products, last_page):
    with open(PARTIAL_FILE, 'w', encoding='utf-8') as f:
        json.dump({'products': products, 'last_page': last_page}, f, ensure_ascii=False, indent=2)

# Faz chamada paginada à API
def fetch_page(page):
    params = {
        'page':          page,
        'page_size':     PAGE_SIZE,
        'fields':        FIELDS,
    }
    r = requests.get(API_URL, params=params, timeout=20)
    r.raise_for_status()
    return r.json()

# Programa principal
def main():
    os.makedirs(os.path.dirname(PARTIAL_FILE), exist_ok=True)

    products, seen_codes, current_page = load_partial()
    print(f'🧼 Produtos já salvos: {len(products)} | Retomando da página {current_page}...\n')

    # Busca página inicial para descobrir total
    first_data = fetch_page(1)
    total_count = first_data.get('count', 0)
    page_count  = first_data.get('page_count', total_count // PAGE_SIZE + 1)

    pbar = tqdm(total=total_count, desc='Verificando base')

    # Percorre da página atual até o fim
    for page in range(current_page, page_count + 1):
        try:
            data = fetch_page(page)
            for prod in data.get('products', []):
                pbar.update(1)
                if is_complete(prod) and has_hair_tag(prod):
                    code = prod['code']
                    if code not in seen_codes:
                        seen_codes.add(code)
                        products.append(extract(prod))

            save_partial(products, page + 1)
            time.sleep(0.2)

        except Exception as e:
            print(f'\n⚠️ Erro na página {page}: {e}')
            print('⏳ Último progresso salvo. Pode continuar de onde parou.')
            break

    pbar.close()
    print(f'\n✅ Total coletado com categoria hair: {len(products)}')
    print(f'📦 Arquivo salvo em: {PARTIAL_FILE}')

if __name__ == '__main__':
    main()