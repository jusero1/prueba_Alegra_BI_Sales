# Religión, Espiritualidad & Riqueza Nacional

Es importante resaltar que el archivo "Hallazgos sobre la Espiritualidad, Religión & Riqueza.pptx" corresponde netamente a la presentación de los resultados del analisis

---

## Resumen ejecutivo

Este proyecto presenta **dos argumentos visuales** construidos a partir de datos reales del Pew Research Center (2023) y el Banco Mundial (WDI 2023):

1. **La paradoja del rico creyente** — EE. UU. se desvía +23 puntos porcentuales sobre la tendencia secular global: es tan rico como Francia o Japón, pero ora a diario el doble que ambos.
2. **La religión no es un bloque monolítico** — La afiliación religiosa no garantiza ni la creencia en dogmas tradicionales ni el rechazo a espiritualidades alternativas. Israel (99% afiliado, 61% cree en el más allá) es el caso más elocuente.

---

## Fuentes de datos

| Dataset | Fuente | Año | Variables clave |
|---|---|---|---|
| Spirituality & Religion — % of adults who… | [Pew Research Center](https://www.pewresearch.org) | 2023 | Afiliación, oración diaria, creencia en más allá, energía en naturaleza |
| GDP per cápita, PPP (USD corrientes) | [Banco Mundial — WDI](https://data.worldbank.org/indicator/NY.GDP.PCAP.PP.CD) | 2023 | `NY.GDP.PCAP.PP.CD` |
| Dataset integrado | Elaboración propia | 2023 | 35 países, 9 variables, ISO3 |

---

## Metodología

### Integración de datasets
El dataset de religión no incluía códigos de país estandarizados. Se construyó manualmente un diccionario de mapeo **ISO 3166-1 alfa-3** para los 36 países, y se realizó un `LEFT JOIN` sobre el código ISO hacia el dataset del Banco Mundial.

```python
# Ejemplo del mapeo
ISO3_MAP = {
    'U.S.': 'USA',  'UK': 'GBR',  'South Korea': 'KOR', ...
}
df_rel['ISO3'] = df_rel['Country'].map(ISO3_MAP)
df = df_rel.merge(df_gdp[['Country Code', 'gdp_ppp_2023']],
                  left_on='ISO3', right_on='Country Code')
```

### Regresión log-lineal (Viz 1)
Para cuantificar el outlier de EE. UU. se ajustó un modelo `pray_daily ~ log(GDP_PPP)` **excluyendo EE. UU.** del ajuste. Esto permite medir con precisión cuánto se desvía respecto a la norma secular:

| Métrica | Valor |
|---|---|
| R² (sin EE.UU.) | **0.653** |
| Predicción para EE.UU. | ~21% |
| Valor real EE.UU. | **44%** |
| **Desviación** | **+23.2 puntos porcentuales** |

### Brecha de identidad (Viz 3)
Se calculó `gap = pct_afiliados − pct_creen_en_más_allá` para cada país, revelando que la mayor brecha no es Israel sino **India (+56pp)** — un hallazgo que enriquece la narrativa.

---

## 📊 Visualizaciones

### Viz 1 — *El Outlier de los Ricos Creyentes* `[Python · Plotly]`
Scatter plot interactivo con:
- **Eje X**: GDP per cápita PPP 2023 (miles USD)
- **Eje Y**: % de adultos que oran a diario
- **Color**: Región geográfica
- **Tamaño de burbuja**: % de adultos religiosamente afiliados
- **Línea punteada**: Tendencia secular log-lineal (sin EE. UU.)
- **Estrella dorada**: EE. UU. como outlier narrativo con anotación y flecha

> *«El 44% de los adultos en EE. UU. ora diariamente, superando por mucho a pares ricos como Japón (21%) o Francia (18%)»*

---

### Viz 2 — *Ranking de Religiosidad Comparada* `[Python · Plotly]`
Panel doble de barras horizontales ordenadas por oración diaria:
- Columna izquierda: % ora a diario
- Columna derecha: % afiliación religiosa
- EE. UU. destacado en dorado en ambos paneles

---

### Viz 3 — *La Religión No Es Un Bloque Monolítico* `[R · ggplot2 · patchwork]`
Composición de tres paneles con tema oscuro:

| Panel | Tipo | Mensaje |
|---|---|---|
| Superior izq. | Scatter con diagonal 1:1 | Afiliación ≠ Creencia. Israel como diamante dorado. |
| Superior der. | Dumbbell chart | Ranking de la brecha afiliación–más allá por país |
| Inferior | Slope chart (3 ejes) | Tres dimensiones independientes de la religiosidad |

---

## Hallazgos clave

- 🇺🇸 **EE. UU.** es el mayor outlier entre países ricos: ora el doble que sus pares económicos, con una desviación de +23pp sobre la tendencia secular.
- 🇮🇱 **Israel** tiene una brecha de **38pp** entre afiliación (99%) y creencia en vida tras la muerte (61%) — la narrativa más rica del dataset entre países de ingresos altos.
- 🇮🇳 **India** registra la mayor brecha absoluta del dataset: **+56pp** (99% afiliado, 43% cree en más allá).
- 🇨🇱🇯🇵 **Chile y Japón** son los únicos países donde la creencia en **energía en la naturaleza supera la afiliación religiosa formal**: espiritualidad sin institución.
- La teoría de la secularización se cumple con R² = 0.65 en 34 países — pero colapsa completamente frente a EE. UU.

---

## 🛠️ Stack tecnológico

| Herramienta | Uso |
|---|---|
| `Python 3.11` | Pipeline principal de datos y visualizaciones interactivas |
| `pandas` | Carga, limpieza, merge y transformación de datos |
| `numpy` | Regresión log-lineal y cálculo de R² |
| `plotly` | Visualizaciones interactivas (scatter + barras) |
| `R 4.3` | Visualizaciones estáticas multi-panel |
| `ggplot2` | Motor gráfico base en R |
| `ggrepel` | Etiquetas sin solapamiento en scatter |
| `patchwork` | Composición de paneles múltiples |
| `scales` | Formato de ejes y porcentajes |

---

## Cómo reproducir el análisis

### Python (Jupyter Notebook)
```bash
# 1. Instalar dependencias
pip install pandas numpy plotly

# 2. Colocar los CSV originales en la misma carpeta que el notebook
# 3. Ejecutar todas las celdas en orden
jupyter notebook religion_gdp_analysis.ipynb
```

### R (Script)
```r
# 1. Instalar dependencias (solo la primera vez)
install.packages(c("ggplot2","dplyr","tidyr","ggrepel","scales","patchwork"))

# 2. Asegurarse de que religion_gdp_merged_2023.csv está en el directorio de trabajo
# 3. Ejecutar el script
source("religion_identity_gaps.R")
```

---

## 🧠 Concepto de Storytelling: Empatía Predictiva

El enfoque narrativo de este proyecto aplica **empatía predictiva** — un marco de comunicación que identifica la emoción que el dato debería provocar antes de diseñar la visualización.

Para este caso, la emoción objetivo es la **sorpresa constructiva**:

> *"Creía entender cómo funciona la religión en el mundo moderno — pero los datos muestran que la realidad es más compleja y más interesante de lo que pensaba."*

Esto se traduce en decisiones de diseño concretas:
- La **línea de tendencia sin EE. UU.** construye expectativa antes de revelar el outlier.
- La **diagonal 1:1** en el panel de Israel establece la "norma" que luego se rompe.
- El **dorado** para los casos más sorprendentes crea una jerarquía visual de atención.
- Las **anotaciones narrativas** reemplazan títulos de ejes genéricos por preguntas retóricas.

---

## Autor

Proyecto desarrollado por Juan Sebastian Segura.

---

*Datos: Pew Research Center · Banco Mundial WDI · Año de referencia: 2023*
