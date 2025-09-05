#if UNITY_EDITOR
using UnityEngine;

// PrefabDropSnap.cs
// A component for 2d objects for prefabs to be drag-and-dropped in grid positions.

// Made by Hammercroft (https://github.com/Hammercroft)

// This work is dedicated to the public domain under the CC0 1.0 Universal Public Domain Dedication.
// You are free to use, modify, distribute, and perform the work, even for commercial purposes, all without asking permission.
// For more information, see: https://creativecommons.org/publicdomain/zero/1.0/

[ExecuteAlways]
public class PrefabDropSnap : MonoBehaviour
{
    [Tooltip("Grid size in world units.")]
    public float gridSize = 1f;

    [Tooltip("Offset within the grid cell (e.g., 0.5 means centered).")]
    public Vector2 offset = new Vector2(0.5f, 0.5f);

    void Update()
    {
        if (!Application.isPlaying) // still good practice
        {
            Vector3 pos = transform.position;
            pos.x = Mathf.Floor(pos.x / gridSize) * gridSize + offset.x;
            pos.y = Mathf.Floor(pos.y / gridSize) * gridSize + offset.y;
            pos.z = 0f;
            transform.position = pos;
        }
    }
}
#endif
