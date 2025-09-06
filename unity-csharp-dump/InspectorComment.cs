using UnityEngine;

[AddComponentMenu("Utilities/Inspector Comment")]
[DisallowMultipleComponent]
public class InspectorComment : MonoBehaviour
{
    [Header("Notes")]
    [Tooltip("Free-form notes for this object. Saved with the scene/prefab.")]
    [TextArea(3, 10)]
    [SerializeField] private string text = "";

    #if UNITY_EDITOR
    // Ensure changes are saved when edited in the Inspector (scene or prefab mode).
    private void OnValidate()
    {
        UnityEditor.EditorUtility.SetDirty(this);
    }
    #endif
}
