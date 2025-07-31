import json
from tqdm import tqdm

INPUT_FILE  = r'C:\Users\vitor\Documents\HairSense\database\base_produtos.json'
OUTPUT_FILE = r'C:\Users\vitor\Documents\HairSense\database\hair_filtered.json'
IMAGE_BASE  = 'https://static.openbeautyfacts.org/images/products'

def extract_image_url(item: dict) -> str | None:
    """
    1) usa os campos diretos se existirem
    2) monta URL a partir de `images.front_en` ou `images.front`
    """
    # 1) campos diretos
    url = item.get('image_front_url') or item.get('image_url')
    if url:
        return url.strip()

    # 2) monta via código e imgid
    code   = item.get('code', '').strip()
    images = item.get('images', {}) or {}
    for key in ('front_en', 'front'):
        img = images.get(key)
        if isinstance(img, dict):
            imgid = img.get('imgid') or img.get('id')
            if code and imgid:
                return f"{IMAGE_BASE}/{code}/{key}.{imgid}.full.jpg"
    return None

def has_hair_tag(tags: list) -> bool:
    return any('hair' in tag.lower() for tag in tags or [])

def main():
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        products = json.load(f)

    hair_count   = 0
    code_count   = 0
    name_count   = 0
    ing_count    = 0
    img_count    = 0
    saved_count  = 0
    filtered     = []

    for prod in tqdm(products, desc='Filtrando produtos', unit='itens'):
        tags = prod.get('categories_tags') or []
        if not has_hair_tag(tags):
            continue
        hair_count += 1

        code        = prod.get('code', '').strip()
        name        = prod.get('product_name', '').strip()
        ingredients = prod.get('ingredients_text', '').strip()
        img_url     = extract_image_url(prod)

        code_count += bool(code)
        name_count += bool(name)
        ing_count  += bool(ingredients)
        img_count  += bool(img_url)

        if code and name and ingredients and img_url:
            filtered.append({
                'code':             code,
                'name':             name,
                'image_front_url':  img_url,
                'ingredients_text': ingredients
            })
            saved_count += 1

    # resumo
    print(f'''
Total com "hair" em categories_tags:       {hair_count}
 - têm código de barras:                   {code_count}
 - têm nome de produto:                    {name_count}
 - têm ingredients_text preenchido:        {ing_count}
 - têm imagem (front):                     {img_count}
Produtos com todos os campos preenchidos:   {saved_count}
''')

    # salva resultado
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(filtered, f, ensure_ascii=False, indent=2)

    print(f'Arquivo salvo em: {OUTPUT_FILE}')

if __name__ == '__main__':
    main()