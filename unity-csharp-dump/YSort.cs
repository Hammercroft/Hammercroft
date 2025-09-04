using UnityEngine;

// YSort.cs
// Y-Sorting component for 2d objects.

// Made by Hammercroft (https://github.com/Hammercroft)

// This work is dedicated to the public domain under the CC0 1.0 Universal Public Domain Dedication.
// You are free to use, modify, distribute, and perform the work, even for commercial purposes, all without asking permission.
// For more information, see: https://creativecommons.org/publicdomain/zero/1.0/

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
        float yPos = transform.position.y;

        float finalOffset = 0f;

        if (sr.sprite != null && useSpriteBottom)
        {
            // Sprite bottom in local space
            float bottomLocal = sr.sprite.bounds.min.y;

            switch (offsetUnit)
            {
                case OffsetUnit.World:
                    finalOffset = bottomLocal * transform.lossyScale.y + offset;
                    break;
                case OffsetUnit.Local:
                    finalOffset = (bottomLocal + offset) * transform.lossyScale.y; // scale local offset
                    break;
                case OffsetUnit.Pixel:
                    finalOffset = bottomLocal + (offset / sr.sprite.pixelsPerUnit);
                    break;
            }
        }
        else
        {
            switch (offsetUnit)
            {
                case OffsetUnit.World:
                    finalOffset = offset;
                    break;
                case OffsetUnit.Local:
                    finalOffset = offset * transform.lossyScale.y; // scale local offset
                    break;
                case OffsetUnit.Pixel:
                    finalOffset = offset / sr.sprite.pixelsPerUnit;
                    break;
            }
        }

        yPos += finalOffset;

        sr.sortingOrder = -(int)(yPos * sortingMultiplier);
    }

    private void OnDrawGizmos()
    {
        if (sr == null) sr = GetComponent<SpriteRenderer>();
        if (sr.sprite == null) return;

        Vector3 worldPos = transform.position;
        float finalOffset = 0f;

        if (sr.sprite != null && useSpriteBottom)
        {
            float bottomLocal = sr.sprite.bounds.min.y;

            switch (offsetUnit)
            {
                case OffsetUnit.World:
                    finalOffset = bottomLocal * transform.lossyScale.y + offset;
                    break;
                case OffsetUnit.Local:
                    finalOffset = (bottomLocal + offset) * transform.lossyScale.y;
                    break;
                case OffsetUnit.Pixel:
                    finalOffset = bottomLocal + (offset / sr.sprite.pixelsPerUnit);
                    break;
            }
        }
        else
        {
            switch (offsetUnit)
            {
                case OffsetUnit.World:
                    finalOffset = offset;
                    break;
                case OffsetUnit.Local:
                    finalOffset = offset * transform.lossyScale.y;
                    break;
                case OffsetUnit.Pixel:
                    finalOffset = offset / sr.sprite.pixelsPerUnit;
                    break;
            }
        }

        worldPos.y += finalOffset;

        // Draw reference point
        Gizmos.color = Color.green;
        Gizmos.DrawSphere(worldPos, 0.05f);

        // Draw a line down to the transform origin
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(transform.position, worldPos);
    }
}
