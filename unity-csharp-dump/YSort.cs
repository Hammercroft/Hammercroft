using UnityEngine;

// YSort.cs
// Y-Sorting component for 2d objects.

// Made by Hammercroft (https://github.com/Hammercroft)

// This work is dedicated to the public domain under the CC0 1.0 Universal Public Domain Dedication.
// You are free to use, modify, distribute, and perform the work, even for commercial purposes, all without asking permission.
// For more information, see: https://creativecommons.org/publicdomain/zero/1.0/

[ExecuteAlways]
[RequireComponent(typeof(SpriteRenderer))]
public class YSort : MonoBehaviour
{
    private SpriteRenderer sr;

    public enum OffsetUnit { World, Local, Pixel }

    [Tooltip("Multiplier for sorting order. Higher = finer separation.")]
    public int sortingMultiplier = 16;

    [Tooltip("If true, offset is applied from the sprite bottom. If false, from the transform position.")]
    public bool useSpriteBottom = false;

    [Tooltip("Offset from the reference point (bottom or center) in the selected unit.")]
    public float offset = 0f;

    [Tooltip("Units used for the offset: world units, local units (scaled), or pixels.")]
    public OffsetUnit offsetUnit = OffsetUnit.World;

    void Awake()
    {
        sr = GetComponent<SpriteRenderer>();
    }

    void LateUpdate()
    {
        if (sr == null) sr = GetComponent<SpriteRenderer>();
        if (sr.sprite == null) return;

        float yPos = transform.position.y;
        float finalOffset = CalculateOffset();

        yPos += finalOffset;

        // Sorting order based on Y position + offset
        sr.sortingOrder = -(int)(yPos * sortingMultiplier);
    }

    private float CalculateOffset()
    {
        if (sr.sprite == null) return 0f;

        if (useSpriteBottom)
        {
            // Bottom of the sprite in *world units*
            float bottomWorld = sr.bounds.min.y - transform.position.y;

            switch (offsetUnit)
            {
                case OffsetUnit.World:
                    return bottomWorld + offset;

                case OffsetUnit.Local:
                    return (sr.sprite.bounds.min.y + offset) * transform.lossyScale.y;

                case OffsetUnit.Pixel:
                    // Convert pixel offset into world units, scaled properly
                    return bottomWorld + (offset / sr.sprite.pixelsPerUnit) * transform.lossyScale.y;
            }
        }
        else
        {
            switch (offsetUnit)
            {
                case OffsetUnit.World:
                    return offset;

                case OffsetUnit.Local:
                    return offset * transform.lossyScale.y;

                case OffsetUnit.Pixel:
                    return (offset / sr.sprite.pixelsPerUnit) * transform.lossyScale.y;
            }
        }

        return 0f;
    }

    private void OnDrawGizmos()
    {
        if (sr == null) sr = GetComponent<SpriteRenderer>();
        if (sr.sprite == null) return;

        Vector3 worldPos = transform.position;
        float finalOffset = CalculateOffset();
        worldPos.y += finalOffset;

        // Draw reference point
        Gizmos.color = Color.green;
        Gizmos.DrawSphere(worldPos, 0.05f);

        // Draw a line down to the transform origin
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(transform.position, worldPos);
    }
}
