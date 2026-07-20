# "Sistema Agéntico de Vigilancia y Compliance para Mercados de Capitales"

## El problema

El lavado de dinero y la manipulación de mercado no son delitos menores. El **Grupo de Acción Financiera Internacional (GAFI)** estima que entre el 2% y el 5% del PIB mundial se lava anualmente — entre 800,000 millones y 2 billones de dólares. El mercado de capitales es uno de los vehículos preferidos por su volumen, su velocidad de ejecución y el anonimato relativo que ofrecen las estructuras de intermediación.

Los patrones de manipulación no son nuevos — el GAFI los tiene documentados desde 1989. Lo que ha cambiado es la velocidad y sofisticación con la que operan:

- Un manipulador ejecuta spoofing en **45 segundos** y obtiene su ganancia antes de que ningún analista abra su pantalla
- Una red de structuring puede fragmentar millones de pesos en **cientos de operaciones** diseñadas para parecer normales individualmente
- El spoofing coordinado entre dos actores en **diferentes instituciones** es invisible para cualquiera de las dos por separado

**Por qué los métodos tradicionales no son suficientes:**

| Limitación | Impacto |
|------------|--------|
| Un analista no puede revisar miles de operaciones diarias buscando patrones | La mayoría de las anomalías pasan desapercibidas |
| El patrón no está en una operación — está en la relación entre muchas | Se requiere correlación que ningún humano puede hacer a escala |
| El manipulador opera en segundos, el analista revisa al día siguiente | El daño ya ocurrió cuando se detecta |
| La revisión manual es inconsistente — depende del analista, su experiencia y su estado de ánimo | Patrones idénticos reciben tratamiento diferente |
| Las instituciones medianas y pequeñas no tienen presupuesto para sistemas propietarios | Cumplen con hojas de cálculo o no cumplen |

**Por qué se necesitan sistemas inteligentes:**

Un agente de inteligencia artificial no se cansa, no tiene sesgos, no olvida un patrón que vio hace seis meses y puede correlacionar simultáneamente miles de operaciones buscando relaciones que ningún analista detectaría manualmente. No reemplaza al Oficial de Cumplimiento — lo potencia: el agente procesa el volumen, el OPLE aplica el criterio.

**El marco internacional que lo respalda:**

El GAFI emite **40 Recomendaciones** que los países miembro están obligados a implementar en su legislación local. No es una sugerencia — los países que no cumplen entran en lista gris o negra del GAFI con consecuencias económicas directas: restricciones de acceso al sistema financiero internacional, alertas a instituciones extranjeras y deterioro de la calificación de riesgo país.

```
GAFI emite 40 Recomendaciones
        ↓
Países miembro las implementan en ley local
        ↓
México  → LFPIORPI + LMV
Colombia → SARLAFT
Chile   → Ley 19.913
Brasil  → Lei 9.613
        ↓
Instituciones financieras obligadas a detectar y reportar
        ↓
¿Cómo detectan a escala? ← aquí está la brecha
```

**La brecha en Latinoamérica:**

La obligación legal existe en todos los países de la región. La tecnología para cumplirla eficientemente no está democratizada. Las instituciones grandes tienen sistemas propietarios con costos de implementación que van de cientos de miles a millones de dólares. Las instituciones medianas y pequeñas — que representan la mayoría del mercado — cumplen manualmente, con hojas de cálculo, o simplemente no cumplen con la profundidad que la ley exige.

Este sistema existe para cerrar esa brecha.

**Patrones que abarca el sistema:**

El mercado de capitales concentra una variedad amplia de patrones de manipulación y lavado documentados por el GAFI y los reguladores internacionales. El sistema está diseñado para detectarlos todos en su madurez. El MVP cubre los cinco patrones de mayor impacto y menor complejidad de implementación con datos sintéticos:

| # | Patrón | MVP | Alcance posterior |
|---|--------|-----|------------------|
| 1 | Structuring | ✅ | |
| 2 | Wash Trading | ✅ | |
| 3 | Cuentas dormidas que despiertan | ✅ | |
| 4 | Concentración inusual | ✅ | |
| 5 | Spoofing — análisis estático de órdenes canceladas | ✅ | |
| 6 | Pump & Dump | | ⏳ Iteración 2 |
| 7 | Operaciones sin lógica económica | | ⏳ Iteración 2 |
| 8 | Churning | | ⏳ Iteración 2 |
| 9 | Colusión entre cuentas | | ⏳ Iteración 3 |
| 10 | Spoofing en tiempo real | | ⏳ Iteración 3 |
| 11 | Layering | | ⏳ Iteración 3 |
| 12 | Marking the Close | | ⏳ Iteración 3 |
| 13 | Front Running | | ⏳ Iteración 4 |
| 14 | Insider Trading | | ⏳ Iteración 4 |
| 15 | Parking | | ⏳ Iteración 4 |

---

## Descripción

Sistema de vigilancia de mercado de capitales basado en agentes de inteligencia artificial con compliance integrado. Detecta operaciones sospechosas de manipulación de mercado y lavado de dinero, genera alertas con evidencia estructurada y somete cada caso a supervisión humana antes de escalar al regulador.

## Contexto

Proyecto desarrollado para el **Concurso de IA Agéntica en Mercado de Capitales**. Integra dos verticales del sector financiero:

- **Riesgo, Compliance y AML** — monitoreo normativo, prevención de lavado de dinero, generación automática de reportes regulatorios
- **Trading y Ejecución** — market surveillance, detección de anomalías estadísticas, generación de indicios y alertas por instrumento

## Glosario de términos

Cada etapa del flujo utiliza el término preciso para su contexto. Esta distinción es relevante tanto técnica como jurídicamente:

| Término | Ámbito | Definición en este sistema |
|---------|--------|---------------------------|
| Anomalía | Estadístico | Desviación medible respecto al comportamiento histórico normal. Lo que el agente detecta en los datos. |
| Indicio | Legal | Señal que apunta hacia una posible operación inusual. Término que usa la LFPIORPI. El agente genera indicios, no certezas. |
| Alerta | Operativo | Notificación generada por el sistema para que el OPLE atienda un indicio. Tiene nivel (ALTO/MEDIO/BAJO) y plazo. |
| Hallazgo | Auditoría | Resultado de la investigación del OPLE sobre una alerta. El OPLE confirma o descarta el indicio. |
| Operación inusual | Legal | Determinación formal del OPLE conforme al Art. 17 LFPIORPI. Activa el plazo legal de reporte a la UIF. |

```
Agente detecta anomalía estadística
        ↓
Sistema registra el indicio (término legal)
        ↓
Sistema genera una alerta (término operativo para el OPLE)
        ↓
OPLE investiga y documenta el hallazgo (término de auditoría)
        ↓
OPLE determina si es operación inusual (término legal — activa plazo Art. 18 LFPIORPI)
        ↓
Se genera el Reporte de Operación Inusual (ROU) para la UIF
```

---

## Flujo general del sistema

```
Datos de operaciones → Agente detecta anomalía → Registra indicio → Genera alerta
→ OPLE investiga el hallazgo → Confirma operación inusual → Genera ROU para la UIF
```

---

## Marco regulatorio de referencia

Los patrones detectados por el sistema tienen fundamento en la legislación mexicana vigente y en los estándares internacionales de prevención de lavado de dinero:

| Ordenamiento | Artículos relevantes | Aplicación en el sistema |
|---|---|---|
| Código Penal Federal (CPF) | Art. 400 Bis | Operaciones con recursos de procedencia ilícita — base legal del lavado de dinero |
| Ley del Mercado de Valores (LMV) | Art. 370, 373, 374 | Uso de información privilegiada, manipulación de mercado, agravantes |
| Ley Federal PLD/FT (LFPIORPI) | Art. 17, 18, 32 | Actividades vulnerables, definición de operación inusual, obligación de reporte a la UIF |
| Tipologías GAFI | TR-2019 y posteriores | Patrones internacionales de lavado reconocidos por el regulador mexicano |

El agente no determina la existencia de un delito — esa facultad corresponde a la autoridad judicial. El sistema detecta **indicios** y genera evidencia estructurada para que el Oficial de Prevención de Lavado de Dinero (OPLE) evalúe si procede el reporte a la UIF.

```
Agente detecta indicio
    → OPLE evalúa
        → UIF investiga
            → FGR determina si hay delito
                → Juez sentencia
```

---

## Patrones que detecta

Los patrones se clasifican en dos categorías según su naturaleza temporal. Esta distinción determina la arquitectura técnica requerida para cada uno.

### Categoría 1 — Análisis estático (fin de jornada)

Estos patrones requieren el panorama completo de la jornada para ser detectados. El patrón solo es visible cuando se acumulan suficientes operaciones a lo largo del día o de múltiples jornadas. Constituyen el núcleo del MVP.

**Criterio de clasificación:** Si el patrón requiere sumar, correlacionar o comparar operaciones de toda la jornada, corresponde a análisis estático.

| # | Patrón | Agente | Dificultad | Qué detecta | Ventana |
|---|--------|--------|-----------|------------|---------|
| 1 | Structuring | `structuring_agent` | Baja | Operaciones fragmentadas deliberadamente por debajo del umbral de reporte | 7-30 días |
| 2 | Wash Trading | `wash_trading_agent` | Media | Cuenta que compra y vende el mismo instrumento sin lógica económica | 1-7 días |
| 3 | Colusión | `colusion_agent` | Alta | Correlación estadística entre cuentas que se benefician mutuamente de forma repetida | 30-90 días |
| 4 | Pump & Dump | `pump_dump_agent` | Media | Acumulación de posición para inflar el precio, seguida de venta masiva | Días |
| 5 | Operaciones sin lógica económica | `no_logic_agent` | Baja | Comprar a precio superior al de mercado o vender por debajo — pérdida intencional como mecanismo de lavado | 1 día |
| 6 | Cuentas dormidas que despiertan | `dormant_agent` | Baja | Cuenta sin actividad durante meses o años que de forma repentina registra operaciones de alto volumen | Histórico |
| 7 | Concentración inusual | `concentration_agent` | Media | Una cuenta acapara un porcentaje significativo del volumen total de un instrumento en la jornada | 1 día |
| 8 | Churning | `churning_agent` | Media | Operador que ejecuta transacciones excesivas en la cuenta de un cliente para generar comisiones artificiales | 30 días |

**Arquitectura — análisis estático:**

```
Cierre de jornada (trigger programado)
        ↓
Orquestador Strands Agents
  ├── Filtro SQL Structuring      → ¿hay candidatos? → Agente Structuring
  ├── Filtro SQL Wash Trading     → ¿hay candidatos? → Agente Wash Trading
  ├── Filtro SQL Cuentas Dormidas → ¿hay candidatos? → Agente Cuentas Dormidas
  ├── Filtro SQL Concentración   → ¿hay candidatos? → Agente Concentración
  └── Filtro SQL Spoofing         → ¿hay candidatos? → Agente Spoofing
         │
         ▼
   Consolidador de Indicios → Base de datos de alertas → Dashboard QuickSight
                                                                ↓
                                                   OPLE: escalar o descartar
```

**Justificación de la arquitectura multi-agente especializada:**

Cada patrón tiene su propio agente con un prompt específico y exclusivo para ese tipo de anomalía. Esta decisión de diseño tiene implicaciones técnicas, operativas y económicas directas:

| Criterio | Agente único que hace todo | Un agente por patrón (decisión adoptada) |
|----------|---------------------------|-------------------------------------------|
| Prompt | Largo y genérico — intenta cubrir todos los patrones | Quirúrgico y específico — enfocado en un solo patrón |
| Riesgo de cambios | Modificar el prompt para un patrón puede afectar la detección de otros sin notarlo | Cambios en un agente no afectan a los demás |
| Calibración | Compleja — un umbral afecta todo | Independiente por patrón |
| Costo | El modelo siempre se invoca aunque no haya candidatos | Si el filtro no encuentra candidatos, el agente no se invoca — costo cero |
| Mantenimiento | Un fallo afecta todo el sistema | Un fallo está aislado al patrón afectado |

**Flujo por agente — filtro SQL primero, modelo solo si hay candidatos:**

```
Filtro SQL — reglas determinísticas, sin costo de modelo
        ↓
¿Encontró candidatos?
    NO → agente no se invoca → costo cero para este patrón hoy
    SÍ → agente recibe únicamente los registros candidatos
        ↓
        Prompt especializado — el agente solo sabe de su patrón
        Analiza, correlaciona, evalúa contra marco regulatorio
        Genera indicio con evidencia estructurada
```

El orquestador ejecuta todos los filtros, invoca solo los agentes que tienen trabajo real y consolida los resultados en el dictamen final. Un día sin candidatos de wash trading es un día en que el agente de wash trading no existe para el sistema — y no cobra.

---

### Categoría 2 — Análisis en tiempo real

Estos patrones se completan en segundos o minutos. Si el análisis se realiza al cierre de jornada, el daño ya ocurrió y el manipulador ya obtuvo el beneficio. El objetivo del análisis en tiempo real no es prevenir — es **documentar con precisión de timestamp** para construir el expediente legal con evidencia irrefutable.

**Criterio de clasificación:** Si el patrón se completa en segundos o minutos, requiere análisis en tiempo real.

| # | Patrón | Dificultad | Qué detecta | Ventana |
|---|--------|-----------|------------|---------|
| 1 | Spoofing | Media | Orden de volumen inusual cancelada en menos de 60 segundos con beneficiario identificado en la ventana | Segundos |
| 2 | Layering | Media | Múltiples órdenes en cascada a diferentes precios para simular profundidad de mercado falsa | Segundos |
| 3 | Front Running | Alta | Operador que ejecuta posición propia antes de procesar una orden grande de cliente | Segundos a minutos |
| 4 | Marking the Close | Media | Operaciones que manipulan el precio de cierre en los últimos minutos de la jornada | Últimos 15 minutos |

**Por qué no se utiliza LLM en tiempo real:**

La invocación de un modelo de lenguaje requiere entre 2 y 5 segundos de latencia. La detección en tiempo real exige respuesta en menos de 100 milisegundos. Por esta razón, la capa de tiempo real utiliza **reglas determinísticas en AWS Lambda**, no agentes Strands.

**Arquitectura — análisis en tiempo real:**

```
BMV / Casa de bolsa genera orden
        ↓
Kinesis Data Streams
(buffer que absorbe ráfagas de miles de eventos por segundo)
        ↓
AWS Lambda — reglas determinísticas (< 100ms)
  → ¿El volumen de la orden supera el 20% del volumen diario del instrumento?
  → ¿La orden fue cancelada en menos de 60 segundos?
  → ¿Existe un beneficiario identificado en esa ventana temporal?
  → Si cumple los criterios → marca el evento como sospechoso
        ↓
    ┌─────────────────────────────┐
    │                             │
DynamoDB                        SNS
(evidencia con timestamp        (notificación inmediata
exacto e inmutable)              al equipo de vigilancia)
        │
        ↓
Al cierre de jornada → Strands Agent analiza todos los eventos marcados
  → Correlaciona eventos entre sí
  → Identifica al beneficiario en el histórico
  → Genera alerta con narrativa completa para el OPLE
```

**Stack adicional para análisis en tiempo real:**

| Capa | Tecnología | Función |
|------|------------|---------|
| Ingesta | Kinesis Data Streams | Recepción del flujo de órdenes en tiempo real |
| Procesamiento | AWS Lambda | Reglas determinísticas, detección inmediata |
| Evidencia | DynamoDB | Almacenamiento de eventos con timestamp exacto |
| Notificación | SNS | Alerta inmediata al equipo de vigilancia |
| Análisis posterior | Strands Agents + Bedrock | Correlación y generación de narrativa al cierre de jornada |

---

### Mecanismo de manipulación: Spoofing

El spoofing es la forma de manipulación de mercado tipificada en el **Art. 373 fracción I de la LMV** como "celebrar operaciones de simulación en cuanto al volumen o precio de valores".

**Mecanismo:**

El manipulador publica una orden de venta de volumen inusualmente alto — no con intención de ejecutarla, sino para generar una señal psicológica en el mercado. El efecto no proviene del precio de la orden sino del **volumen**: los demás participantes interpretan que un actor grande desea salir de su posición, lo que genera presión vendedora y caída del precio.

```
Manipulador publica orden de venta: 500,000 títulos
    → Participantes interpretan: "alguien grande quiere salir"
    → Vendedores bajan sus precios para ejecutar antes que el grande
    → Precio cae por presión psicológica del volumen
    → Manipulador compra a precio deprimido
    → Cancela la orden fantasma
    → Precio regresa a su nivel real
    → Manipulador obtiene ganancia por la diferencia
```

**Variables que evalúa el agente:**

El agente no evalúa el precio de la orden de forma aislada — evalúa el conjunto de variables en contexto:

| Variable | Señal de alerta | Señal de operación legítima |
|---|---|---|
| Volumen de la orden vs promedio diario | > 20% del volumen diario del instrumento | Dentro del rango histórico normal |
| Precio de la orden vs precio de mercado | Dentro del rango normal (el precio no es la señal) | — |
| Tiempo hasta cancelación | < 60 segundos | Orden vigente durante la jornada |
| Beneficiario identificado en la ventana | Cuenta que operó y se benefició del movimiento | Sin beneficiario correlacionado |
| Historial de la cuenta | Patrón repetido en días anteriores | Primera ocurrencia sin contexto |
| Evento de mercado que justifique el movimiento | Sin noticias ni eventos del emisor en la ventana ±24h | Noticia o hecho relevante publicado que justifique el movimiento |

**Consulta de noticias — sub-agente especializado:**

El sistema incorpora un sub-agente con responsabilidad única: determinar si existe una justificación pública conocida para un movimiento inusual de precio o volumen. El agente de vigilancia consume el resultado sin conocer ni depender de la implementación interna.

```python
@tool
def hay_justificacion_publica(ticker: str, fecha: str) -> bool:
    """Determina si existe una noticia o evento material publicado
    que justifique un movimiento inusual de precio o volumen.
    Retorna True si existe justificación conocida, False si no hay indicios.
    Fuente actual: Finnhub API (cobertura limitada a emisoras del IPC)."""
    ...
```

El agente de spoofing consume únicamente el booleano:

```python
if not hay_justificacion_publica(ticker, fecha):
    score += FACTOR_AGRAVANTE  # sin explicación pública → sube la sospecha
else:
    score -= FACTOR_ATENUANTE  # noticia material identificada → baja la sospecha
```

Flujo de evaluación:

```
Agente detecta anomalía estadística de volumen/precio
        ↓
Sub-agente consulta noticias por ticker en ventana ±24h
        ↓
¿Existe noticia material? (resultados trimestrales, fusión, escándalo, cambio regulatorio)
        ↓
    True  → factor atenuante — baja el score de sospecha
    False → factor agravante — sube el score de sospecha
```

**Fuentes de noticias disponibles:**

| Fuente | URL | Plan gratuito | Cobertura BMV | Notas |
|--------|-----|---------------|---------------|-------|
| Finnhub | `finnhub.io` | Sí (60 req/min) | Sí — emisoras del IPC | Noticias + sentimiento por ticker. Endpoint: `/news?symbol=AMXL.MX` |
| NewsAPI | `newsapi.org` | Sí (100 req/día) | Parcial — depende de fuentes indexadas | Agrega cientos de medios. Búsqueda por nombre de emisora o ticker |
| Alpha Vantage | `alphavantage.co` | Sí (con límites) | Parcial | Noticias + análisis de sentimiento por ticker |
| Polygon.io | `polygon.io` | Sí (plan básico) | Parcial | Endpoint `/v2/reference/news`. Mejor cobertura en NYSE/NASDAQ |
| Yahoo Finance | `finance.yahoo.com` | Sí (no oficial) | Sí — emisoras grandes | Vía librería `yfinance` en Python, sin API key requerida |
| Emisnet (BMV) | `emisnet.bmv.com.mx` | Sí (público) | Completa — todas las emisoras | Fuente oficial. Sin API formal — requiere scraping. Hechos relevantes obligatorios por ley |
| CNBV hechos relevantes | `cnbv.gob.mx` | Sí (público) | Completa | Comunicados que las emisoras están legalmente obligadas a publicar |

**Diseño para madurez progresiva:**

El sub-agente está diseñado para crecer de forma independiente sin afectar al agente de vigilancia. La interfaz es invariable — siempre devuelve un booleano — y la implementación interna evoluciona conforme madura el proyecto:

| Etapa | Fuentes activas | Cobertura |
|-------|----------------|-----------|
| MVP (actual) | Finnhub + NewsAPI + yfinance | ~35 emisoras del IPC — las de mayor volumen y mayor riesgo de manipulación |
| Iteración 2 | Anteriores + Emisnet (BMV) | IPC + emisoras medianas con hechos relevantes publicados |
| Iteración 3 | Anteriores + CNBV hechos relevantes | Cobertura amplia del mercado mexicano |
| Maduro | Anteriores + feed institucional (Bloomberg/Refinitiv) | Cobertura completa incluyendo noticias internacionales que afectan emisoras locales |

**Limitación documentada del MVP:** Emisnet y los hechos relevantes de la CNBV no disponen de API formal — su integración requiere scraping estructurado. Esta capacidad está identificada como mejora de la iteración 2 y no bloquea el funcionamiento del MVP.

---

**Spoofing coordinado:**

La variante más sofisticada involucra dos actores: uno publica la orden fantasma y otro ejecuta la operación beneficiada. Ambos parecen independientes en el registro de operaciones.

**Limitación de jurisdicción de datos:**

El agente opera sobre los datos de una sola institución. Si el manipulador publica la orden fantasma en la casa de bolsa A y el beneficiario ejecuta en la casa de bolsa B, el beneficiario es invisible desde la perspectiva del agente:

```
Casa de bolsa A ve:
  → Cuenta X publica orden de 500,000 títulos  @ 10:23:45
  → Orden cancelada en 45 segundos             @ 10:24:30
  → Precio se mueve en la dirección esperada
  → ¿Quién se benefició en otra institución?   → invisible
```

Lo que el agente sí puede detectar dentro de una sola institución:

| Observable | Dentro de la misma casa de bolsa | Beneficiario en otra institución |
|------------|----------------------------------|----------------------------------|
| Orden fantasma con volumen inusual | ✓ | ✓ |
| Cancelación en menos de 60 segundos | ✓ | ✓ |
| Movimiento de precio en la ventana | ✓ | ✓ |
| Beneficiario que operó y se benefició | ✓ si opera en la misma casa | ✗ invisible |

**Rol del agente en el spoofing coordinado:** el agente construye la mitad del expediente — documenta la orden fantasma con timestamp exacto, la cancelación y el movimiento de precio. Esa evidencia es suficiente para que la CNBV cruce con sus datos consolidados y cierre el otro lado.

**Quién cierra el caso:** la CNBV opera el **SIVA (Sistema de Vigilancia del Mercado)** con visibilidad consolidada de todas las instituciones. Con el expediente parcial generado por el agente, la CNBV puede correlacionar:

```
CNBV cruza todas las instituciones:
  Casa A: Cuenta X cancela orden grande  @ 10:23:45  ← expediente del agente
  Casa B: Cuenta Y compra masivo         @ 10:23:47  ← visible solo para CNBV
  → Correlación temporal → investigación formal
```

Esta limitación es inherente a la arquitectura del mercado, no al sistema. La solución completa requiere acceso al SIVA, que corresponde al regulador. El agente cumple su función: detectar, documentar y escalar con evidencia estructurada.

**Layering — variante del spoofing:**

En lugar de una sola orden grande, el manipulador publica múltiples órdenes a diferentes precios para simular profundidad de mercado falsa. El efecto es el mismo: generar una percepción artificial de oferta o demanda que no existe.

```
Book de órdenes manipulado con layering:
  VENDEDORES
  100,000 títulos @ $43.00  ← orden fantasma
   80,000 títulos @ $42.50  ← orden fantasma
   60,000 títulos @ $42.00  ← orden fantasma
   10,000 títulos @ $41.50  ← orden real
```

El mercado percibe una pared de oferta que no existe. Cuando el precio se mueve en la dirección deseada, todas las órdenes fantasma se cancelan simultáneamente.

---

### Patrones híbridos

Algunos patrones tienen detección en tiempo real para documentar la evidencia y análisis profundo al cierre de jornada para construir el expediente:

| Patrón | Tiempo real | Cierre de jornada |
|--------|-------------|-------------------|
| Spoofing | Lambda detecta y documenta el evento con timestamp exacto | Strands correlaciona todos los eventos del día de esa cuenta y genera narrativa |
| Front Running | Lambda detecta la ventana temporal entre orden del cliente y operación propia | Strands cruza con historial del operador y detecta patrón repetido |

---

### Niveles de sofisticación (roadmap)

- **Nivel 1 (MVP):** Patrones estáticos — misma cuenta, mismo instrumento, ventana corta
- **Nivel 2:** Cuentas diferentes, mismo beneficiario final (prestanombres)
- **Nivel 3:** Fragmentación con ruido e instrumentos correlacionados
- **Nivel 4:** Análisis en tiempo real, cross-market, derivados y latencia artificial

El MVP cubre los niveles 1 y 2 con análisis estático únicamente. El análisis en tiempo real corresponde al roadmap posterior.

**Fuente de los patrones:** Tipologías GAFI, Circulares CNBV, casos publicados por la SEC (EE.UU.), guías de la UIF México.

### Patrones de referencia (alcance futuro)

Estos patrones requieren información externa al flujo normal de operaciones: registros de propiedad, noticias corporativas, datos de empleados o estructuras de beneficiarios finales. Se documentan como referencia del potencial del sistema, no como parte del roadmap inmediato.

| Patrón | Descripción | Requisito especial |
|--------|-------------|-------------------|
| Insider Trading | Operación con información privilegiada antes de un anuncio corporativo | Cruce con fuentes externas: noticias, comunicados, acceso a sistemas internos del emisor |
| Parking | Transferencia temporal de acciones a tercero para ocultar la propiedad real | Datos de estructura corporativa y beneficiarios finales (UBO) registrados en CNBV |

Cuando el sistema alcance madurez operativa, estos patrones son candidatos naturales para integración con feeds de noticias, registros mercantiles y bases de beneficiarios finales.

---

## Stack tecnológico

| Capa | Tecnología | Función |
|------|------------|---------|
| Análisis en tiempo real | AWS Lambda | Reglas determinísticas, detección y documentación inmediata |
| Ingesta en tiempo real | Kinesis Data Streams | Buffer para flujo de órdenes en tiempo real |
| Orquestación | Strands Agents (Python) | Arquitectura multi-agente, un agente especializado por patrón |
| Modelo de lenguaje | AWS Bedrock (Claude Opus 3) | Análisis contextual, correlación de patrones y generación de narrativa |
| Modelo auxiliar | AWS Bedrock (Claude Haiku 3) | Sub-agente de noticias — clasificación simple True/False |
| Conexión a datos | MCP (postgres-mcp-server) | Acceso de solo lectura a la base de datos de operaciones |
| Base de datos | PostgreSQL (EC2) | Operaciones, órdenes, alertas, regulaciones |
| Dashboard | Amazon QuickSight | Visualización para el Oficial de Cumplimiento |
| Supervisión humana | Steering handlers con approval interrupts | El agente detecta, el OPLE decide |
| Trazabilidad | CloudWatch Logs | Auditoría completa de cada decisión del agente |
| Datos (MVP) | Dataset sintético | Generado con base en estándares reales: FIX Protocol, CNBV, UIF |

**Viabilidad del dataset sintético — argumento técnico:**

El uso de datos sintéticos no es una limitación del sistema — es una decisión de diseño deliberada y defendible. Tres razones:

**1. Los patrones están definidos por la ley y los estándares internacionales, no por suposiciones**

La LFPIORPI, las tipologías GAFI y las circulares de la CNBV describen con precisión cómo se ve cada patrón en los datos. El dataset sintético replica ese comportamiento documentado:

```
Structuring según GAFI:
  Múltiples operaciones deliberadamente por debajo del umbral de reporte
  en una ventana de días, misma cuenta, mismo instrumento

Structuring sintético:
  Misma estructura — números configurables, patrón idéntico
```

**2. La estructura de los datos es universal — FIX Protocol**

Todos los intermediarios financieros del mundo registran operaciones bajo el mismo estándar: el FIX Protocol. Una operación en la BMV tiene los mismos campos que una en NYSE o en cualquier mercado regulado. El dataset sintético replica esa estructura — no es imaginaria, es el estándar que usa la industria.

**3. La conexión a datos reales es un paso de configuración, no de rediseño**

Cuando el sistema se conecte a datos reales de una institución, el adaptador multi-cliente mapea su esquema al modelo canónico y el agente opera de forma idéntica. El tuning de umbrales con datos reales es el paso siguiente — no un prerequisito para demostrar que el sistema funciona.

```
Dataset sintético  → demuestra que el sistema detecta los patrones correctamente
Datos reales       → afina los umbrales para el perfil específico de la institución
```

Si se cuestiona la validez del dataset sintético, la respuesta es: los patrones que detecta el sistema están definidos por los mismos estándares — GAFI, FIX Protocol, LFPIORPI — que los propios reguladores reconocen y exigen. No se está simulando algo imaginario — se está simulando exactamente lo que la ley describe.
| Seguridad | IAM roles de solo lectura | Mínimo privilegio por agente |
| Pool de conexiones | RDS Proxy | Gestión de conexiones simultáneas en producción (no requerido en MVP) |

**Criterio de selección de modelo:**

El sistema opera con dos modelos con responsabilidades distintas:

| Tarea | Modelo | Justificación |
|-------|--------|---------------|
| Análisis de patrones + narrativa regulatoria | Claude Opus 3 | Requiere razonar sobre múltiples variables simultáneamente, correlacionar cuentas y generar evidencia que soporte un expediente legal. Se elige el modelo de mayor capacidad de razonamiento dado que el output es evidencia con potencial peso regulatorio. **Claude Sonnet 3.5 es suficiente** para el caso de uso y representa el balance óptimo entre capacidad y costo si el volumen de análisis escala |
| Sub-agente de noticias (True/False) | Claude Haiku 3 | Tarea de clasificación simple — busca y determina si existe una noticia. No requiere razonamiento complejo |

El costo no es el argumento principal para esta decisión — dado que el análisis se ejecuta una vez al día, la diferencia económica entre modelos es prácticamente irrelevante. El criterio es la **calidad del diagnóstico**: el output del agente es evidencia que un Oficial de Cumplimiento va a evaluar y potencialmente escalar al regulador. Ese output debe ser preciso, bien razonado y con referencias normativas correctas. Opus no se justifica porque hay un humano en el loop — el OPLE — que corrige antes de escalar. Sonnet es el balance correcto entre capacidad de razonamiento y suficiencia para el caso de uso.

---

## Control de costos — filtro previo al modelo

Que el agente corra una vez al día no garantiza que el costo sea bajo. Lo que determina el costo es el **volumen de tokens** que llega al modelo, no la frecuencia de ejecución. Una institución con 10,000 operaciones diarias que las manda todas al modelo en una sola invocación puede generar un costo significativo.

El diseño correcto es un **filtro previo determinístico** que descarta el 95% de las operaciones antes de invocar al modelo:

```
10,000 operaciones del día
        ↓
Reglas determinísticas en SQL + Python  ← sin costo de modelo
        ↓
~50-200 operaciones sospechosas
        ↓
Modelo analiza únicamente lo que pasó el filtro
        ↓
Costo real = costo de analizar 50-200 operaciones, no 10,000
```

El modelo nunca ve las operaciones normales. El costo lo determina cuántas operaciones pasan el filtro, no el volumen total de la jornada.

**Parámetros configurables por patrón:**

Cada patrón tiene sus propios criterios de filtro y sus propios umbrales. Si los umbrales son configurables, el sistema se adapta a cualquier institución — tamaño, mercado, perfil de riesgo — sin modificar el código.

> ⚠️ **Pendiente de desarrollo:** El diseño detallado de los criterios de filtro, umbrales configurables y lógica de pre-selección para cada uno de los cinco patrones del MVP se documentará en una sección dedicada conforme avance la implementación. Cada patrón requiere su propio análisis de qué variables determinan si una operación merece ser evaluada por el modelo y cuáles son los umbrales razonables para el mercado mexicano.

**Nota de diseño — calibración como proceso vivo:**

Los umbrales no son un parámetro que se configura una vez y se olvida. La calibración es un proceso continuo que hace al sistema más robusto con el tiempo:

```
Umbrales teóricos (ley + GAFI + criterio experto)
        ↓
Validación con dataset sintético — se corrige lo que genera ruido excesivo
        ↓
Validación con datos reales de la institución — la realidad siempre sorprende
        ↓
Ajuste con feedback del OPLE — "esto es normal en nuestra operación"
        ↓
Ajuste por cambios del mercado — volatilidad, nuevos instrumentos, nuevos actores
        ↓
Se vuelve a ajustar... siempre
```

El tuning tiene dos enemigos que deben mantenerse en balance permanente:

| Problema | Causa | Consecuencia |
|----------|-------|--------------|
| Falso positivo | Umbral demasiado bajo | OPLE recibe demasiadas alertas, las ignora, el sistema pierde credibilidad |
| Falso negativo | Umbral demasiado alto | Indicios reales no se detectan, el sistema no cumple su función |

Ese balance es diferente para cada institución — una casa de bolsa conservadora tolera más falsos positivos, una con poco personal de cumplimiento necesita menos ruido. Por eso los umbrales son configurables por cliente, no fijos en el código. La calibración no es una etapa del proyecto — es una práctica operativa permanente que define la madurez del sistema.

Un factor adicional que influye directamente en la calidad de la calibración es el **nivel de experiencia del OPLE**. El oficial de cumplimiento no es un actor pasivo — sus decisiones de confirmar o descartar alertas retroalimentan implícitamente la percepción de qué tan bien está calibrado el sistema:

| Perfil del OPLE | Efecto en la calibración |
|-----------------|-------------------------|
| Experimentado y conocedor del mercado | Descarta falsos positivos con criterio sólido, confirma indicios reales con evidencia adicional — el sistema mejora con su uso |
| En curva de aprendizaje | Puede descartar alertas válidas por no reconocer el patrón, o confirmar falsos positivos por exceso de cautela |
| Inexperto o desatento | Puede degradar la efectividad del sistema si sus decisiones no tienen fundamento técnico |

Esto no es un defecto del sistema — es la realidad de cualquier herramienta que depende de criterio humano. La mitigación está en el diseño:

- La **guía de investigación por patrón** en la app Flutter reduce la dependencia del conocimiento previo del OPLE — el sistema le dice qué verificar aunque no lo sepa de memoria
- El **agente de consulta** le da contexto regulatorio exacto antes de que tome una decisión — no decide a ciegas
- Toda decisión queda registrada con timestamp y justificación — si un patrón de malas decisiones emerge, es auditable
- Los umbrales los configura la institución, no el OPLE individualmente — un solo operador no puede degradar el sistema unilateralmente

**Riesgo principal de costo — filtro mal calibrado:**

```
Umbral demasiado bajo → pasan demasiadas operaciones al modelo → costo se multiplica
Umbral demasiado alto → se pierden indicios reales → falsos negativos
```

La calibración de umbrales es una de las decisiones de diseño más importantes del sistema y se resolverá con el dataset sintético antes de la implementación.

---

## Adaptabilidad a múltiples clientes

**Problema:** Cada institución financiera tiene su base de datos estructurada de forma diferente — distintos nombres de tablas, campos y tipos de datos para los mismos conceptos. Una solución genérica no puede ejecutar consultas directas sobre cualquier esquema.

**Solución: Capa de adaptador con modelo canónico**

```
Base de datos del cliente (cualquier estructura)
        ↓
Adaptador (mapeo de campos al modelo canónico)
        ↓
Modelo canónico (estructura interna invariable)
        ↓
Agente (opera exclusivamente sobre el modelo canónico)
```

**Ejemplo de mapeo entre clientes:**

| Campo canónico | Cliente A | Cliente B | Cliente C |
|---|---|---|---|
| operacion_id | id_transaccion | txn_id | folio_op |
| monto | monto_operacion | amount | importe_total |
| fecha | fecha_mov | transaction_date | fch_operacion |
| cuenta | num_cuenta | account_no | cta_cliente |

**Implementación técnica: transformación en memoria**

El adaptador no crea tablas intermedias ni duplica datos. Es una transformación al vuelo en memoria:

```
BD cliente → SELECT → row (dict) → adaptador.normalizar() → OperacionCanonica (RAM) → agente
```

```python
# Modelo canónico — estructura interna invariable del sistema
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal

@dataclass
class OperacionCanonica:
    id_operacion: str
    cuenta: str
    tipo: str          # "compra" | "venta"
    ticker: str
    cantidad: int
    precio: Decimal
    timestamp: datetime
    broker: str
```

```python
# Adaptador Cliente A — casa de bolsa con SQL Server, campos en inglés
class AdaptadorClienteA:
    def normalizar(self, row: dict) -> OperacionCanonica:
        return OperacionCanonica(
            id_operacion=row["trade_id"],
            cuenta=row["account_number"],
            tipo="compra" if row["side"] == "BUY" else "venta",
            ticker=row["symbol"],
            cantidad=int(row["qty"]),
            precio=Decimal(str(row["price"])),
            timestamp=row["exec_time"],
            broker=row["trader_id"],
        )
```

```python
# Adaptador Cliente B — SOFOM con MySQL, campos en español, datos combinados
class AdaptadorClienteB:
    def normalizar(self, row: dict) -> OperacionCanonica:
        return OperacionCanonica(
            id_operacion=str(row["folio"]),
            cuenta=row["num_cuenta"],
            tipo=row["operacion"].lower(),
            ticker=row["emisora"] + "." + row["serie"],
            cantidad=int(row["titulos"]),
            precio=Decimal(str(row["precio_ejec"])),
            timestamp=datetime.strptime(row["fecha_hora"], "%d/%m/%Y %H:%M:%S"),
            broker=row["clave_operador"],
        )
```

**Principios del adaptador:**

- No se duplican datos — no existe tabla espejo que mantener sincronizada
- No se incurre en costo de almacenamiento adicional — el dato permanece en la base de datos del cliente
- No existe proceso ETL nocturno — la transformación es instantánea en el momento de la lectura
- No se modifica la base de datos del cliente — únicamente se requieren permisos de lectura
- Si el cliente modifica su esquema, solo se actualiza su adaptador — el núcleo del sistema no se toca

**Lo que sí se persiste:** únicamente los resultados propios del sistema — alertas generadas, scores de riesgo y decisiones del OPLE. Los datos de operaciones del cliente nunca se copian.

**Modelo de implementación por cliente:**

1. Mapeo de campos al modelo canónico (1-2 semanas)
2. Configuración de umbrales según la regulación aplicable (días)
3. El agente opera de forma idéntica para todos los clientes

**Modelo de negocio:**

- Núcleo genérico (agente + reglas + dashboard) → producto estándar con licencia recurrente
- Adaptador por cliente → servicio de implementación con tarifa única
- Cada cliente nuevo se incorpora con menor esfuerzo porque el núcleo ya existe

---

## Estrategia de recuperación de información (Vectorless RAG)

**Justificación:** El sistema no utiliza embeddings ni bases de datos vectoriales porque:

- Los datos de operaciones son estructurados — SQL directo es más preciso y económico
- Las búsquedas regulatorias requieren precisión exacta ("Circular 115/2024", "Art. 3") — BM25 no falla en coincidencias exactas de texto
- No existe dependencia de modelos de embeddings que pueden deprecarse — re-indexar implica pérdida de trabajo acumulado
- Una sola instancia de PostgreSQL cubre ambas necesidades
- El sistema es auditable: si un resultado no aparece, la causa es identificable de forma inmediata

**Fuentes de datos del agente:**

```
Agente detecta anomalía estadística
  ├── SQL directo → Base de datos de operaciones (¿qué hizo esta cuenta?)
  ├── BM25 full-text → Regulaciones en PostgreSQL (¿qué establece la norma?)
  └── SQL directo → Históricos (¿esta cuenta tiene antecedentes?)
        │
        ▼
  Modelo analiza el conjunto → Registra indicio → Genera alerta con evidencia + referencia regulatoria exacta
```

**Comparativa de decisión:**

| Criterio | Embeddings + Vector DB | BM25 + SQL (decisión adoptada) |
|----------|----------------------|-------------------------------|
| Costo mensual | Alto (Pinecone/Weaviate + modelo de embeddings) | Bajo (PostgreSQL ya disponible) |
| Precisión en búsquedas exactas | Deficiente ("Circular 115" puede traer cualquier circular) | Excelente (coincidencia exacta) |
| Fragilidad | Alta (deprecación del modelo implica re-indexar todo) | Baja (las palabras clave no cambian) |
| Auditabilidad | Difícil (¿por qué trajo este resultado?) | Simple (el query y el resultado son visibles) |
| Infraestructura adicional | Sí (base de datos vectorial separada) | No (misma base de datos de operaciones) |

**¿Cuándo se agregarían embeddings?** Únicamente si se requiere búsqueda semántica conceptual — por ejemplo: "¿existe alguna norma sobre fragmentar operaciones para evadir reportes?" donde las palabras exactas no aparecen en el documento. Para el MVP no es necesario.

---

## Base de conocimiento legislativo

El agente de consulta dispone de una tabla en PostgreSQL con el texto completo de los artículos relevantes, indexada para búsqueda BM25. No es un sistema de embeddings ni RAG vectorial — es búsqueda de texto exacto sobre legislación estructurada.

**Esquema:**

```sql
CREATE TABLE legislacion (
    id            SERIAL PRIMARY KEY,
    ordenamiento  VARCHAR(100),  -- 'LFPIORPI' | 'LMV' | 'CPF' | 'GAFI'
    articulo      VARCHAR(20),   -- 'Art. 17' | 'Art. 373'
    titulo        VARCHAR(200),  -- descripción corta del artículo
    contenido     TEXT NOT NULL, -- texto completo del artículo
    vigente_desde DATE,
    notas         TEXT           -- contexto de aplicación en el sistema
);

CREATE INDEX idx_legislacion_bm25
    ON legislacion
    USING gin(to_tsvector('spanish', contenido || ' ' || titulo));
```

**Contenido inicial — artículos cargados al arranque del sistema:**

| Ordenamiento | Artículos | Aplicación |
|---|---|---|
| Código Penal Federal (CPF) | Art. 400 Bis | Operaciones con recursos de procedencia ilícita |
| Ley del Mercado de Valores (LMV) | Art. 370, 373, 374 | Información privilegiada, manipulación de mercado, agravantes |
| Ley Federal PLD/FT (LFPIORPI) | Art. 17, 18, 32 | Actividades vulnerables, operación inusual, obligación de reporte |
| Tipologías GAFI | TR-2019 relevantes | Patrones internacionales de lavado documentados |

La tabla crece conforme se incorporan nuevos ordenamientos o circulares de la CNBV. Cada artículo nuevo que el equipo de cumplimiento considere relevante se agrega directamente — no requiere re-entrenar ningún modelo.

**Herramienta del agente de consulta:**

```python
@tool
def consultar_legislacion(consulta: str) -> list[dict]:
    """Busca artículos en la base de conocimiento legislativo.
    Retorna el texto completo del artículo con su referencia exacta.
    Usar cuando el OPLE solicite el fundamento legal de un indicio
    o cuando se requiera citar la norma aplicable en el expediente."""
    ...
```

**Por qué BM25 y no embeddings para legislación:**

```
OPLE pregunta: "¿qué dice el Art. 17 LFPIORPI?"
  BM25     → encuentra exactamente el Art. 17                        ✓
  Vectores → puede traer Art. 17, Art. 18, Art. 7 y algo de GAFI    ✗
```

En un expediente legal no se puede citar el artículo equivocado. La precisión exacta no es opcional.

---

## Dashboard QuickSight

Visualización para el Oficial de Cumplimiento:

- Mapa de calor: instrumentos con mayor concentración de alertas
- Línea de tiempo: distribución temporal de indicios detectados
- Scoring por cuenta: clientes con mayor acumulación de puntos de riesgo
- Grafo de relaciones: cuentas vinculadas entre sí (colusión, beneficiario común)
- KPIs operativos: alertas del día, pendientes de revisión, resueltas
- Detalle de alerta: evidencia, patrón detectado, score, referencia regulatoria y recomendación del agente

---

## Dictamen diario

El agente emite un dictamen al cierre de cada jornada **siempre** — con hallazgos o sin ellos. Un día sin alertas también tiene valor informativo y forma parte del expediente de cumplimiento de la institución.

**Estructura del dictamen — jornada sin hallazgos:**

```
DICTAMEN DE VIGILANCIA DE MERCADO
Jornada: 2024-01-15

RESUMEN EJECUTIVO
Instrumentos monitoreados : 847
Operaciones analizadas    : 12,453
Cuentas evaluadas         : 2,891
Contexto de mercado       : Banxico mantuvo tasa sin cambios.
                            Sin hechos relevantes de emisoras del IPC.

La jornada del 15 de enero de 2024 se caracterizó por actividad dentro de
parámetros normales. El volumen operado se mantuvo en línea con el promedio
de los últimos 30 días. No se identificaron concentraciones inusuales,
patrones de fragmentación ni movimientos de precio sin justificación conocida.

Nivel de riesgo de la jornada : BAJO
Alertas generadas             : 0
Acción requerida              : Ninguna
```

**Estructura del dictamen — jornada con hallazgos:**

```
DICTAMEN DE VIGILANCIA DE MERCADO
Jornada: 2024-01-15

RESUMEN EJECUTIVO
Instrumentos monitoreados : 847
Operaciones analizadas    : 12,453
Cuentas evaluadas         : 2,891
Contexto de mercado       : Banxico mantuvo tasa sin cambios.
                            Sin hechos relevantes de emisoras del IPC.

La jornada del 15 de enero de 2024 registró 3 alertas que requieren
revisión del Oficial de Cumplimiento.

ALERTA 1 — Structuring [ALTO]
  Cuenta           : ***4521
  Patrón           : 7 operaciones en 5 días por debajo del umbral de reporte
  Monto acumulado  : $485,000 MXN
  Evidencia        : Operaciones del 10 al 15 de enero, mismo instrumento,
                     montos entre $68,000 y $72,000 por operación
  Referencia legal : Art. 17 LFPIORPI — operación inusual por fragmentación
  Plazo de revisión: Mismo día antes del cierre

ALERTA 2 — Concentración inusual [MEDIO]
  Cuenta           : ***8834
  Patrón           : Acaparó el 34% del volumen total de GFNORTEO en la jornada
  Referencia legal : Art. 373 LMV — manipulación de mercado
  Plazo de revisión: 24 horas hábiles

ALERTA 3 — Cuenta dormida que despierta [BAJO]
  Cuenta           : ***2201
  Patrón           : Sin actividad 14 meses. Operación de $120,000 MXN hoy
  Referencia legal : Art. 17 LFPIORPI — operación inusual por comportamiento atípico
  Plazo de revisión: 72 horas hábiles

Nivel de riesgo de la jornada : ALTO
Alertas generadas             : 3  (1 alta, 1 media, 1 baja)
Acción requerida              : Revisión del OPLE — Alerta 1 antes del cierre de hoy
```

---

## Niveles de alerta y plazos de revisión

El Art. 18 de la LFPIORPI establece un máximo de **3 días hábiles** para reportar una operación inusual a la UIF desde que la institución la **conoce formalmente**.

**¿Cuándo inicia el plazo legalmente?**

El agente genera un **indicio** — no una operación inusual confirmada. La determinación de que una operación es inusual corresponde al criterio del OPLE conforme al Art. 17 LFPIORPI. Por lo tanto, el plazo legal de 3 días hábiles inicia en el momento en que el OPLE valida y confirma la alerta, no cuando el agente la detecta.

```
Agente detecta indicio        ← sospecha técnica, no conocimiento formal
        ↓
OPLE valida y confirma        ← la institución "conoce" formalmente
        ↓                        AQUÍ inicia el plazo legal
3 días hábiles para reportar a la UIF
```

Este criterio tiene fundamento en la cadena de responsabilidades establecida por la propia ley y otorga margen operativo real a la institución sin comprometer el cumplimiento normativo.

**Lo que define el nivel de alerta** no es el plazo legal — ese siempre es 3 días hábiles desde la confirmación del OPLE. Lo que define el nivel es **qué tan rápido debe confirmar el OPLE** para que quede margen suficiente de preparar y enviar el reporte a la UIF:

| Nivel | Criterio | OPLE confirma en | Margen para reporte a UIF | Fundamento |
|-------|----------|------------------|--------------------------|------------|
| ALTO | Patrón confirmado con evidencia sólida, riesgo de que el actor opere al día siguiente | Mismo día hábil | 3 días hábiles completos | Urgencia operativa — el daño puede continuar |
| MEDIO | Indicios claros, patrón en desarrollo | 1 día hábil | 2 días hábiles para preparar reporte | Balance entre investigación y cumplimiento |
| BAJO | Señal débil, primera ocurrencia, sin historial | 2 días hábiles | 1 día hábil para preparar reporte | Límite que respeta el plazo legal sin ahogar al OPLE |

**Registro del timestamp de confirmación:**

```sql
CREATE TABLE alertas (
    ...
    detectada_en   TIMESTAMP NOT NULL,  -- timestamp del agente (indicio técnico)
    confirmada_en  TIMESTAMP,           -- timestamp del OPLE (inicia plazo legal)
    vence_en       DATE,                -- calculado en días hábiles desde confirmada_en
    reportada_uif  TIMESTAMP            -- timestamp del reporte a la UIF
);
```

El calendario de días hábiles de la BMV — incluyendo festivos — vive en PostgreSQL para que el cálculo de vencimiento sea correcto. Sumar 72 horas naturales no es equivalente a 3 días hábiles.

---

## Escalamiento automático por vencimiento de plazo

Si el OPLE no revisa una alerta dentro del plazo establecido, el sistema escala automáticamente a través de **Amazon SNS**. El steering handler publica un único evento y SNS lo distribuye a todos los canales suscritos simultáneamente:

```
Alerta vencida sin revisión
        ↓
Steering handler publica en SNS Topic
        ↓
┌───────────┬───────────┬───────────────┬───────────────┐
↓           ↓           ↓               ↓               ↓
Email      SMS         Email           Slack/Teams     Lambda
OPLE       OPLE        supervisor      canal interno   → registra
                       cumplimiento                    incumplimiento
                                                       en bitácora
```

El steering handler no sabe ni le importa cuántos canales están suscritos — solo publica el evento:

```python
sns.publish(
    TopicArn="arn:aws:sns:us-west-2:338990204655:alerta-vencida",
    Message=json.dumps({
        "alerta_id": alerta_id,
        "nivel": "ALTO",
        "ople": ople_nombre,
        "horas_vencida": horas,
        "patron": patron_detectado,
        "plazo_legal": "Art. 18 LFPIORPI"
    }),
    Subject="⚠️ Alerta de cumplimiento vencida sin revisión"
)
```

Agregar un canal nuevo — WhatsApp Business, Telegram, llamada automática — es una suscripción adicional al topic. El agente y el steering handler no se modifican.

**Escalamiento por nivel:**

| Nivel | Vencimiento | Notificados en el escalamiento |
|-------|-------------|--------------------------------|
| ALTO | +8 horas sin revisión | OPLE + supervisor de cumplimiento + director de operaciones |
| MEDIO | +24 horas sin revisión | OPLE + supervisor de cumplimiento |
| BAJO | +72 horas sin revisión | OPLE |

El escalamiento queda registrado en bitácora con timestamp exacto. Si la institución es auditada, el expediente demuestra que el sistema detectó, notificó y documentó el incumplimiento interno — la responsabilidad recae sobre quien no atendió, no sobre el sistema.

---

## Modos de operación del agente

**Modo batch (silencioso — backend):**

El agente se ejecuta de forma programada al cierre de jornada. No genera salida en consola. Captura el resultado y lo persiste en la base de datos de alertas.

```python
agent = Agent(tools=[...], callback_handler=None)
result = agent("Analiza las operaciones sospechosas de la jornada")
guardar_alerta(result)
log_tokens(result.metrics.accumulated_usage['totalTokens'])
```

**Modo streaming (interfaz web — OPLE):**

El Oficial de Cumplimiento interactúa con el agente desde el dashboard para investigar casos específicos o consultar el marco regulatorio.

```python
@app.post("/chat")
async def chat(request: PromptRequest):
    async def generate():
        async for event in agent.stream_async(request.prompt):
            if "data" in event:
                yield event["data"]
    return StreamingResponse(generate(), media_type="text/plain")
```

**Criterios de selección del modo:**

| Escenario | Modo | Justificación |
|-----------|------|---------------|
| Análisis diario de operaciones | Batch silencioso | Proceso automatizado sin intervención humana |
| OPLE investiga un caso específico | Streaming | Interacción conversacional en tiempo real |
| Generación de reportes para la UIF | Batch silencioso | Se genera y persiste para revisión posterior |
| OPLE consulta el marco regulatorio | Streaming | Respuesta conversacional inmediata |

---

## Sensibilidad del mercado y contexto de liquidez

El impacto de una operación sospechosa depende directamente de la liquidez del instrumento. El agente evalúa el tamaño de la operación en términos relativos, no absolutos.

```
¿La orden es significativa RELATIVA al volumen diario del instrumento?
  → 500,000 títulos en AMXL (volumen diario: 10M) = 5%   → dentro del rango normal
  → 500,000 títulos en empresa X (volumen diario: 50,000) = 1,000% → alerta crítica
```

**Factores de sensibilidad para el scoring:**

| Factor | Mayor sensibilidad (más fácil de manipular) | Menor sensibilidad |
|--------|---------------------------------------------|-------------------|
| Liquidez | Baja (pocos títulos operados por día) | Alta (millones operados por día) |
| Horario | Apertura, cierre, hora de menor actividad | Horas de mayor volumen operado |
| Profundidad del book | Pocas órdenes en el libro | Book con múltiples niveles de precio |
| Tipo de participantes | Predominantemente retail | Institucionales y retail |
| Mercado | Mercado pequeño (BMV) | Mercado de alta liquidez (NYSE) |

El agente requiere una tabla de referencia con el volumen promedio diario por instrumento para contextualizar cada operación.

---

## Factores que justifican movimientos de precio

Entender qué mueve el precio de forma legítima es la base para distinguir un movimiento normal de uno manipulado. El agente evalúa si alguno de estos factores estaba activo en la ventana temporal del movimiento detectado.

| Categoría | Factor | Impacto típico |
|-----------|--------|----------------|
| Emisora | Resultados trimestrales mejor o peor de lo esperado | Alto — movimiento violento e inmediato |
| Emisora | Anuncio de dividendos, aumento o cancelación | Medio |
| Emisora | Fusión, adquisición o escisión | Alto |
| Emisora | Cambio de CEO, CFO u director relevante | Medio |
| Emisora | Emisión de nuevas acciones (dilución) | Medio — precio baja |
| Emisora | Recompra de acciones | Medio — precio sube |
| Emisora | Hecho relevante publicado en CNBV/Emisnet | Variable |
| Macroeconómico | Decisión de tasas Banxico | Alto — afecta todo el mercado |
| Macroeconómico | Decisión de la Fed (EE.UU.) | Alto — afecta mercados emergentes |
| Macroeconómico | Tipo de cambio inusual | Medio — impacta exportadoras e importadoras |
| Macroeconómico | Dato de inflación o PIB | Medio |
| Sectorial | Nueva regulación que afecta al sector | Alto para el sector |
| Sectorial | Movimiento del precio del petróleo | Alto para energéticas |
| Sectorial | Entrada de competidor relevante | Medio |
| Mercado | Fecha de vencimiento de futuros y opciones BMV | Medio — volatilidad esperada |
| Mercado | Entrada o salida del IPC | Alto — fondos indexados compran o venden masivamente |
| Mercado | Horario de apertura o cierre | Volatilidad natural esperada |

**Fuentes automatizables vs conocimiento institucional:**

En Latinoamérica la disponibilidad de información estructurada y automatizable es limitada comparada con mercados desarrollados. Algunos factores tienen API pública; otros dependen del conocimiento de los participantes del mercado.

| Factor | ¿Automatizable? | Fuente |
|--------|-----------------|--------|
| Hechos relevantes de la emisora | Parcial | Finnhub, NewsAPI, yfinance — cobertura limitada al IPC |
| Decisión de tasas Banxico | Sí | Banxico API REST (`banxico.org.mx/SieAPIRest`) |
| Tipo de cambio | Sí | Banxico API REST |
| Decisión Fed EE.UU. | Sí | FRED API (`fred.stlouisfed.org/docs/api`) |
| Inflación / PIB | Sí | INEGI API pública |
| Vencimiento de derivados BMV | Sí | Calendario estático cargado en PostgreSQL |
| Cambio de dirección, fusiones | No | Emisnet sin API formal |
| Upgrades/downgrades de analistas | No | Bloomberg/Refinitiv — información de pago |
| Sentimiento sectorial | No | Conocimiento tácito de los participantes |

---

## Repositorio de contexto institucional

**Problema:** Una parte significativa del contexto que justifica o agrava un movimiento de mercado no está disponible en ninguna API — vive en el conocimiento de los analistas, operadores y especialistas de la institución.

**Solución:** Un repositorio colaborativo donde cualquier usuario interno con conocimiento relevante puede registrar contexto de mercado. El agente consulta este repositorio junto con las fuentes automáticas antes de emitir su diagnóstico.

```
Fuentes automáticas (APIs)              Repositorio institucional (humanos)
        ↓                                           ↓
Finnhub, Banxico, FRED, INEGI       Analista registra nota sobre FEMSA
Calendario de vencimientos          Operador detecta presión en sector bancario
        ↓                           Área de research publica cambio regulatorio
        └──────────────┬────────────────────────────┘
                       ↓
              PostgreSQL BM25
                       ↓
              Agente consulta ambas fuentes
                       ↓
              Diagnóstico con contexto completo
```

**Quién puede contribuir:**

El repositorio no es propiedad del OPLE — es un activo de la institución. Cualquier usuario interno con conocimiento relevante puede registrar contexto:

| Rol | Tipo de contexto que aporta |
|-----|-----------------------------|
| Analista de renta variable | Movimientos esperados por resultados, cambios en la empresa |
| Operador de mesa de dinero | Presión inusual observada en algún instrumento o sector |
| Área de research | Notas de análisis, cambios de perspectiva sobre emisoras |
| Área de riesgos | Alertas macro, tipo de cambio, tasas |
| OPLE | Contexto de investigaciones en curso que no son públicas |

El conocimiento tácito de la institución — el que vive en la cabeza de los participantes — se convierte en conocimiento estructurado y consultable. Ese activo tiene valor más allá del agente de vigilancia.

**Esquema en PostgreSQL:**

```sql
CREATE TABLE contexto_mercado (
    id          SERIAL PRIMARY KEY,
    fecha       DATE NOT NULL,
    ticker      VARCHAR(20),        -- NULL si es macro o sectorial
    tipo        VARCHAR(30),        -- 'hecho_relevante' | 'macro' | 'sectorial' | 'otro'
    fuente      VARCHAR(100),       -- 'Banxico' | 'analista' | 'research' | 'OPLE'
    descripcion TEXT NOT NULL,      -- texto libre que el usuario registra
    cargado_por VARCHAR(50),
    timestamp   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_contexto_bm25
    ON contexto_mercado
    USING gin(to_tsvector('spanish', descripcion));
```

**Herramienta del agente:**

```python
@tool
def buscar_contexto_mercado(ticker: str, fecha: str) -> list[dict]:
    """Busca contexto de mercado registrado por usuarios internos
    para una emisora y fecha específica. Complementa las fuentes
    automáticas con conocimiento institucional no disponible vía API."""
    ...
```

El agente no distingue si el contexto vino de una API o de un analista — evalúa el conjunto y razona sobre él. La calidad del diagnóstico mejora directamente con la calidad del contexto disponible.

---

## Fuentes para la estructura de datos

- **FIX Protocol** — estándar internacional de mensajes de trading (órdenes, ejecuciones, cancelaciones)
- **ISO 20022** — mensajería financiera internacional
- **UIF** — formato oficial del Reporte de Operaciones Inusuales (documento público)
- **CNBV** — disposiciones aplicables a casas de bolsa
- **GAFI (FATF)** — tipologías de lavado de dinero con casos documentados
- **BMV** — especificaciones técnicas de feeds de mercado
- **Finnhub.io** — noticias financieras por ticker vía API (cobertura confiable: emisoras del IPC)
- **NewsAPI.org** — agregador de noticias de cientos de medios, búsqueda por nombre de emisora
- **Alpha Vantage** — noticias y sentimiento por ticker
- **Polygon.io** — noticias por ticker, mejor cobertura en mercados de EE.UU.
- **Yahoo Finance (yfinance)** — noticias por ticker sin API key, vía librería Python
- **Emisnet (BMV)** — repositorio oficial de hechos relevantes y comunicados de emisoras (roadmap: integración futura, sin API formal)
- **CNBV hechos relevantes** — comunicados que las emisoras están legalmente obligadas a publicar (roadmap: integración futura)

---

## Aplicabilidad en Latinoamérica

La estructura regulatoria en la región es homogénea porque todos los países siguen las recomendaciones del GAFI. Cada país tiene su implementación local pero el esquema es equivalente:

| País | Regulador financiero | Unidad de inteligencia financiera | Ley base |
|------|---------------------|----------------------------------|----------|
| México | CNBV | UIF (SHCP) | Ley Federal PLD/FT |
| Argentina | CNV | UIF Argentina | Ley 25.246 |
| Colombia | Superfinanciera | UIAF | Ley 526/1999 |
| Chile | CMF | UAF | Ley 19.913 |
| Perú | SMV | UIF Perú | Ley 27.693 |
| Brasil | CVM | COAF | Lei 9.613 |

Los patrones detectados son universales. Los parámetros que varían por país (montos de umbral, formatos de reporte, plazos) se gestionan como configuración, no como cambios de arquitectura. El adaptador multi-cliente aplica en dos dimensiones: esquema de base de datos del cliente y parámetros regulatorios del país.

---

## Expansión sectorial

El sistema se desarrolla con foco en el mercado de valores. Sin embargo, la LFPIORPI en su Art. 17 define un universo de **actividades vulnerables** que va mucho más allá del sector financiero — todas obligadas a reportar operaciones inusuales a la UIF bajo el mismo marco legal.

El núcleo del sistema — detectar indicios, documentar evidencia, notificar al responsable y escalar dentro del plazo legal — es invariable entre sectores. Lo que cambia son los patrones de detección y los umbrales, que se gestionan como configuración.

| Sector | Actividad vulnerable (Art. 17 LFPIORPI) | Patrones relevantes |
|--------|----------------------------------------|---------------------|
| Mercado de valores | Casas de bolsa, operadoras de fondos | Structuring, wash trading, spoofing, pump & dump |
| Sector inmobiliario | Compraventa de inmuebles, notarios, corredores | Operaciones en efectivo, precios atípicos, fragmentación de pagos |
| Bienes de lujo | Joyerías, distribuidoras de autos, galerías de arte | Fragmentación, clientes inusuales, pagos en efectivo |
| Servicios profesionales | Contadores, abogados, consultores | Estructuras corporativas sospechosas, fideicomisos opacos |
| Juegos y sorteos | Casinos, loterías | Lavado a través de premios, fragmentación de apuestas |

El adaptador multi-cliente documentado en este sistema aplica en dos dimensiones:
- **Horizontal** — diferentes instituciones del mismo sector con distintos esquemas de base de datos
- **Vertical** — diferentes sectores económicos con distintos patrones y umbrales regulatorios

Esta expansión es potencial y no forma parte del roadmap inmediato. El MVP y el desarrollo del concurso se enfocan exclusivamente en el mercado de valores.

---

## Requisitos del concurso que cumple

- ✅ Agente autónomo con objetivos claros y medibles
- ✅ Flujos de trabajo multi-step con supervisión humana y trazabilidad completa
- ✅ Integración directa con procesos regulatorios del mercado de capitales
- ✅ Modelo replicable para Iberoamérica (CNBV México, CNV Argentina, CMF Chile)
- ⬜ MVP con evidencia inicial de funcionamiento (en desarrollo)

---

## Estado del proyecto

🟡 En desarrollo — arquitectura definida, implementación en curso conforme avanza el estudio de Strands Agents.

## Siguientes pasos

1. Concluir el curso de Strands Agents (lecciones 07-14)
2. Diseñar el esquema de base de datos
3. Generar dataset sintético con operaciones normales y sospechosas
4. Implementar MVP: agente de structuring + agente de wash trading + orquestador
5. Integrar steering handlers para el flujo de aprobación del OPLE
6. Preparar presentación para el concurso

---

## Roadmap de producto

Las siguientes etapas están identificadas y diseñadas pero no forman parte del MVP ni del alcance del concurso. Se documentan como evolución natural del sistema una vez cubiertas las etapas iniciales.

### Etapa 2 — Aplicativo Flutter

Flutter es el front-end completo del sistema — no es solo una app de alertas. Es la ventana a través de la cual todos los usuarios humanos interactúan con lo que los agentes producen. La parte central es la gestión de casos detectados y el análisis asistido por el agente de consulta. El resto son módulos de soporte que complementan la operación.

**Arquitectura general:**

```
BACKEND — el cerebro
  Agentes de detección      → corren de noche, batch, sin interfaz
  Agente de consulta        → responde preguntas del OPLE bajo demanda
  PostgreSQL                → toda la persistencia
  SNS + SES                 → notificaciones y correos
  FastAPI (EC2)             → expone todo vía REST al frontend

FRONTEND — Flutter (iOS + Android + web desde un solo código)
  Módulo de alertas         → el core del sistema
  Módulo de consulta        → chat con el agente de consulta
  Módulo de configuración  → tuning de umbrales y parámetros
  Módulo de administración → usuarios, roles, permisos
  Módulo de reportes        → generación y envío del ROU
```

**Módulo de alertas — el core:**

El OPLE recibe la notificación SNS, abre la app y gestiona el caso completo sin salir de ella:

```
OPLE recibe notificación SNS
        ↓
Abre app — ve listado de alertas con nivel, plazo y tiempo restante
        ↓
Selecciona alerta — ve dictamen + evidencia + referencias normativas
        ↓
App muestra guía de investigación para ese patrón específico
        ↓
OPLE agrega notas y evidencia adicional
        ↓
¿Procede?
    NO → descarta con justificación → expediente cerrado
    SÍ → "Procede — Generar Reporte"
        ↓
Agente genera el ROU con campos de la UIF prellenados
        ↓
OPLE revisa y aprueba
        ↓
SES envía ROU a UIF + copia a toda la cadena
        ↓
Expediente cerrado — timestamp registrado en PostgreSQL
```

**Módulo de consulta — agente de consulta contextual:**

Cuando el OPLE necesita profundizar en un hallazgo, abre el chat desde la alerta. El agente entra a la conversación ya sabiendo el caso — no es un chat genérico, es una sesión de trabajo acotada a esa alerta específica. La conversación completa queda archivada como parte del expediente.

**Módulo de configuración — tuning de umbrales:**

El responsable de cumplimiento puede ajustar los parámetros de detección desde la app sin tocar la base de datos directamente. Cada cambio queda registrado con timestamp y usuario — trazabilidad completa del tuning:

```
Ver umbrales actuales por patrón
  → Ajustar valor
  → Registrar justificación del cambio
  → Guardar — el sistema usa el nuevo umbral en la próxima jornada
```

**Módulo de administración:**

Gestión de usuarios, roles y permisos. No todos los usuarios tienen acceso a todos los módulos — el OPLE ve alertas, el administrador configura umbrales, el director ve reportes ejecutivos.

**Módulo de reportes:**

Generación del ROU, historial de reportes enviados a la UIF, estado de cada expediente y KPIs operativos para la dirección de cumplimiento.

**Separación de responsabilidades:**

| Capa | Responsabilidad | Quién la opera |
|------|----------------|----------------|
| Agentes | Detectar, analizar, generar indicios | El sistema — automático |
| FastAPI | Exponer datos y acciones vía REST | Backend |
| Flutter | Presentar, gestionar, configurar, reportar | OPLE y administradores |

**Stack de esta etapa:** Flutter + FastAPI (EC2 existente) + Amazon SES.

### Etapa 3 — Análisis en tiempo real

Incorporación de Kinesis Data Streams + Lambda para detección de patrones que se completan en segundos: spoofing, layering, front running y marking the close. Documentado en la sección de Categoría 2 de este README.

### Etapa 4 — Expansión sectorial

Adaptación del sistema a otros sectores sujetos a la LFPIORPI Art. 17: inmobiliario, bienes de lujo, servicios profesionales. Documentado en la sección de Expansión Sectorial de este README.

---

## Naturaleza y alcance del sistema

Este sistema representa una propuesta para la detección de operaciones atípicas en el mercado de valores. No tiene la verdad absoluta — ningún sistema de vigilancia la tiene. Su valor no reside en la certeza sino en la **capacidad de evolucionar**.

El sistema es una hipótesis de detección que se refina con el tiempo:

```
Versión inicial — criterios basados en ley, GAFI y conocimiento del dominio
        ↓
Primera implementación — la realidad del mercado revela casos no anticipados
        ↓
Ajuste de criterios — umbrales, ventanas de tiempo, variables de contexto
        ↓
Nuevos patrones emergen — el mercado siempre encuentra nuevas formas
        ↓
El sistema incorpora nuevos criterios de detección
        ↓
Ciclo continuo — el sistema nunca está terminado, siempre está mejorando
```

Esto no es una limitación — es la naturaleza de cualquier sistema de inteligencia. Los propios reguladores internacionales actualizan sus tipologías GAFI periódicamente porque los patrones de manipulación evolucionan. Un sistema que no evoluciona se vuelve obsoleto.

Lo que sí garantiza el sistema en cualquier etapa de su madurez:

- Consistencia — aplica los mismos criterios a todas las operaciones sin excepción
- Trazabilidad — cada decisión queda documentada y es auditable
- Escalabilidad — nuevos criterios y patrones se incorporan sin rediseñar la arquitectura
- Transparencia — el OPLE siempre sabe por qué el sistema generó un indicio

La arquitectura multi-agente con parámetros configurables fue diseñada precisamente para esto — cada agente es independiente, cada umbral es ajustable, cada nuevo patrón es un agente nuevo que se incorpora sin tocar los existentes. El sistema crece con el conocimiento de quienes lo operan.

**Por qué este es un caso de uso idóneo para inteligencia artificial:**

La detección de operaciones atípicas en el mercado de valores reúne exactamente las características que hacen que la IA sea la herramienta correcta — y que las reglas determinísticas sean insuficientes por sí solas:

| Característica del problema | Por qué requiere IA |
|-----------------------------|---------------------|
| No es determinístico | No existe una regla fija que defina con certeza si una operación es sospechosa — depende del contexto, el historial y la combinación de variables |
| Los patrones evolucionan | Los manipuladores adaptan sus técnicas cuando detectan que son monitoreados — el sistema debe adaptarse con ellos |
| El contexto importa | La misma operación puede ser normal o sospechosa dependiendo del instrumento, el horario, el perfil de la cuenta y el contexto de mercado |
| El volumen es imposible de procesar manualmente | Miles de operaciones diarias requieren un sistema que correlacione en paralelo sin fatiga ni sesgo |
| El conocimiento del dominio es acumulable | Cada decisión del OPLE, cada ajuste de umbral y cada nuevo patrón incorporado hace al sistema más inteligente |

Un sistema de reglas determinísticas puede detectar lo obvio — y de hecho lo hace en la capa de filtro previo. Pero lo obvio ya lo detectan todos. El valor diferencial está en detectar lo sutil: el patrón que no viola ninguna regla individual pero que en conjunto, en contexto y con historial, revela una intención. Eso es exactamente lo que hace un modelo de lenguaje con capacidad de razonamiento.

La IA no reemplaza al regulador ni al OPLE — les da la capacidad de ver lo que antes era invisible por volumen y complejidad.

---

## Nota de diseño — naturaleza del agente

Este sistema no es un asistente conversacional. Es un **agente de diagnóstico** — su modelo de operación es puntual y determinístico:

```
Input:  operaciones registradas de la jornada en PostgreSQL
        ↓
Agente consulta, correlaciona y evalúa contra el marco regulatorio
        ↓
Output: reporte estructurado con alertas, evidencia y referencias normativas
```

La analogía correcta es un médico que interpreta un estudio de laboratorio — no platica con el estudio, lo lee, lo analiza y emite un diagnóstico. De la misma forma, el agente no mantiene una conversación con el usuario: recibe un conjunto de datos, razona sobre ellos y produce un resultado estructurado.

Esta naturaleza puntual tiene implicaciones arquitectónicas directas:

| Característica | Agente conversacional | Este sistema |
|----------------|----------------------|--------------|
| Manejo de sesión | Necesario | No aplica |
| Historial de conversación | Necesario | No aplica |
| Summarization de contexto | Necesario | No aplica |
| Streaming de respuesta | Deseable | No necesario |
| Proceso permanentemente levantado | Necesario | No aplica — cron nocturno |

La infraestructura resultante es intencionalmente simple: un script Python ejecutado por un cron al cierre de jornada sobre un EC2, consultando PostgreSQL e invocando Bedrock únicamente con las operaciones que superaron el filtro de reglas determinísticas.

Toda la complejidad del sistema reside en la calidad del diagnóstico — la precisión de los criterios de detección, la solidez del marco regulatorio y la capacidad del agente para distinguir una operación legítima de un indicio de manipulación. No en la infraestructura.
