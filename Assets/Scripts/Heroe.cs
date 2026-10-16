using UnityEngine;

/// <summary>
/// Héroe del tridente. El tridente es un objeto hijo con su propio sprite y
/// animación, alineado con el personaje, así que se puede mostrar u ocultar
/// sin tocar al personaje.
/// </summary>
public class Heroe : MonoBehaviour
{
    [Tooltip("Muestra el tridente en la mano.")]
    [SerializeField] bool conTridente = true;
    [SerializeField] GameObject tridente;

    public bool ConTridente
    {
        get => conTridente;
        set { conTridente = value; Aplicar(); }
    }

    void Awake() => Aplicar();

    void OnValidate() => Aplicar();

    void Aplicar()
    {
        if (tridente != null) tridente.SetActive(conTridente);
    }
}
