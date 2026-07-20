# Referencias y Documentación

## Alcance del Agente

**Input:** Registro de operaciones ya ejecutadas (una tabla/vista).  
**Output:** Alertas de anomalías basadas en normativa.  

No nos importa:
- Cómo llegó la orden (FIX, API, terminal)
- Dónde está el servidor (AWS, on-premise)
- Qué OMS/EMS usan
- Cómo liquidan (eso es post-trade)

Solo nos importa: **el registro de la operación y detectar patrones sospechosos.**

---

## Campos mínimos de una operación (input del agente)

| Campo | Descripción | Uso en detección |
|-------|-------------|------------------|
| operacion_id | ID único | Trazabilidad |
| timestamp | Fecha/hora ejecución | Ventanas temporales |
| cuenta_id | Quién operó | Patrones por cliente |
| instrumento | Qué se operó (ticker) | Wash trading, spoofing |
| tipo | Compra / Venta | Detectar auto-operación |
| cantidad | Número de títulos | Volumen inusual |
| precio | Precio de ejecución | Manipulación de precio |
| monto_total | cantidad × precio | Umbrales de reporte |
| contraparte_cuenta | Quién está del otro lado | Colusión |

---

## Documentación para estudiar

### Normativa México (lo que define las reglas de detección)

- **CNBV** - Disposiciones generales aplicables a casas de bolsa
  - https://www.cnbv.gob.mx
  - Circular Única de Casas de Bolsa (requisitos de compliance)
  
- **UIF** - Unidad de Inteligencia Financiera
  - https://www.gob.mx/uif
  - Formatos de Reportes de Operaciones Inusuales (ROI)
  - Formatos de Reportes de Operaciones Relevantes (ROR)
  - Umbrales de reporte (montos que disparan obligación)

- **Ley del Mercado de Valores** - Marco legal general

### Estándares internacionales

- **GAFI/FATF** - Tipologías de lavado de dinero
  - https://www.fatf-gafi.org
  - Documentos de tipologías (patrones conocidos)
  - 40 Recomendaciones

- **FIX Protocol** - Estructura de datos de operaciones
  - https://www.fixtrading.org
  - Solo para entender los campos estándar de una operación
  - No necesitamos implementar FIX, solo entender la estructura

- **IOSCO** - Organización Internacional de Comisiones de Valores
  - Principios de vigilancia de mercado

### Arquitectura de referencia (contexto, no alcance)

- "capital markets reference architecture" (Google)
- "trading surveillance system architecture"
- "broker dealer technology stack"
- AWS Financial Services - arquitecturas de referencia
- Oracle Financial Services - whitepapers capital markets

---

## Patrones a detectar (basados en normativa)

1. **Wash Trading** - Compra/venta del mismo instrumento, misma cuenta o cuentas relacionadas, ventana corta
2. **Spoofing** - Órdenes grandes que se cancelan antes de ejecutarse (necesitaríamos tabla de órdenes además de ejecuciones)
3. **Structuring** - Operaciones fragmentadas justo debajo del umbral de reporte
4. **Colusión** - Dos cuentas que siempre son contraparte entre sí
5. **Front Running** - Operación propia antes de ejecutar orden grande de cliente
6. **Layering** - Múltiples órdenes a diferentes precios para crear apariencia de demanda/oferta

---

## Notas

- Para el MVP/concurso: datos sintéticos basados en estas estructuras públicas
- En producción: se conectaría a la BD real de operaciones (read-only)
- El agente NO decide, solo detecta y recomienda al compliance officer
