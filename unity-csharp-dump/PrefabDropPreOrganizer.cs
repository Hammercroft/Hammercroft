using UnityEngine;
using UnityEditor;

// PrefabDropPreOrganizer.cs
// A component that automatically re-parents the object into a target object when dropped into the scene.

// Made by Hammercroft (https://github.com/Hammercroft)

// This work is dedicated to the public domain under the CC0 1.0 Universal Public Domain Dedication.
// You are free to use, modify, distribute, and perform the work, even for commercial purposes, all without asking permission.
// For more information, see: https://creativecommons.org/publicdomain/zero/1.0/

[ExecuteAlways]
public class PrefabDropPreOrganizer : MonoBehaviour
{
    [Tooltip("Name of the parent object to look for in the scene.")]
    public string targetParentName = "Doodads";

    void Awake()
    {
        if (Application.isPlaying) return; // Only in edit mode
        if (IsInPrefabStage()) return;     // Do nothing in Prefab Editing Mode

        TryReparent();
    }

    void Reset()
    {
        if (Application.isPlaying) return;
        if (IsInPrefabStage()) return;

        TryReparent();
    }

    private void TryReparent()
    {
        if (string.IsNullOrEmpty(targetParentName)) return;

        GameObject targetObj = GameObject.Find(targetParentName);
        if (targetObj == null) return;

        Transform target = targetObj.transform;
        if (target != null && transform.parent != target)
        {
            transform.SetParent(target, true);
        }
    }

    private bool IsInPrefabStage()
    {
        #if UNITY_EDITOR
        return UnityEditor.SceneManagement.PrefabStageUtility.GetCurrentPrefabStage() != null;
        #else
        return false;
        #endif
    }
}
