from abc import ABC, abstractmethod
from typing import Any


class BaseAdapter(ABC):
    """Contrato que todo adaptador de fuente de datos debe cumplir.
    Traduce el esquema de origen al esquema canónico de surveillance."""

    @abstractmethod
    def to_operador(self, row: dict[str, Any]) -> dict[str, Any]:
        """Traduce un registro de operadores al formato espejo_operadores."""

    @abstractmethod
    def to_cliente(self, row: dict[str, Any]) -> dict[str, Any]:
        """Traduce un registro de clientes al formato espejo_clientes."""

    @abstractmethod
    def to_cuenta(self, row: dict[str, Any]) -> dict[str, Any]:
        """Traduce un registro de cuentas al formato espejo_cuentas."""

    @abstractmethod
    def to_instrumento(self, row: dict[str, Any]) -> dict[str, Any]:
        """Traduce un registro de instrumentos al formato espejo_instrumentos."""

    @abstractmethod
    def to_operacion(self, row: dict[str, Any]) -> dict[str, Any]:
        """Traduce un registro de operaciones al formato espejo_operaciones."""

    @abstractmethod
    def to_orden(self, row: dict[str, Any]) -> dict[str, Any]:
        """Traduce un registro de órdenes al formato espejo_ordenes."""

    @abstractmethod
    def to_posicion(self, row: dict[str, Any]) -> dict[str, Any]:
        """Traduce un registro de posiciones al formato espejo_posiciones."""

    @abstractmethod
    def to_saldo_diario(self, row: dict[str, Any]) -> dict[str, Any]:
        """Traduce un registro de saldos al formato espejo_saldos_diarios."""
