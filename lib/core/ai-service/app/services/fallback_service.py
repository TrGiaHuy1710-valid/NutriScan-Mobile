from typing import Dict, Any

class FallbackService:
    @staticmethod
    def get_food_fallback(message: str = "Unable to estimate calories accurately.") -> Dict[str, Any]:
        """
        Returns the manual input fallback payload for food calorie analysis.
        """
        return {
            "success": False,
            "status": "manual_input_required",
            "message": message,
            "manual_fields": [
                "dish_name",
                "estimated_weight"
            ]
        }

    @staticmethod
    def get_ingredient_fallback() -> Dict[str, Any]:
        """
        Returns the manual input fallback payload for ingredient analysis.
        """
        return {
            "success": False,
            "status": "manual_input_required",
            "manual_fields": [
                "ingredient_list"
            ]
        }

    @staticmethod
    def get_barcode_fallback() -> Dict[str, Any]:
        """
        Returns the fallback payload when a barcode lookup fails.
        """
        return {
            "success": False,
            "status": "barcode_not_found",
            "manual_input_required": True,
            "fields": [
                "product_name",
                "ingredients"
            ]
        }
