﻿using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;
#if UNITY_5_5_OR_NEWER
using UnityEngine.AI;
#endif

public class AdjustPivot : EditorWindow
{
	private const string PIVOT_REFERENCE_POINT_NAME = "__PivotReferencePoint";
	private const string GENERATED_COLLIDER_NAME = "__GeneratedCollider";
	private const string GENERATED_NAVMESH_OBSTACLE_NAME = "__GeneratedNavMeshObstacle";

	private const string UNDO_CREATE_PIVOT_REFERENCE = "Create Pivot Reference";
	private const string UNDO_ADJUST_PIVOT = "Move Pivot";
	private const string UNDO_SAVE_MODEL_AS = "Save Model As";

	private bool createColliderObjectOnPivotChange = false;
	private bool createNavMeshObstacleObjectOnPivotChange = false;

	private GUILayoutOption buttonHeight = GUILayout.Height( 30 );
	private GUILayoutOption headerHeight = GUILayout.Height( 25 );

	private GUIStyle buttonStyle;
	private GUIStyle headerStyle;

	private Vector3 selectionPrevPos;
	private Vector3 selectionPrevRot;

	private Vector2 scrollPos = Vector2.zero;

	[MenuItem( "Window/Adjust Pivot" )]
	private static void Init()
	{
		AdjustPivot window = GetWindow<AdjustPivot>();
		window.titleContent = new GUIContent( "Adjust Pivot" );
		window.minSize = new Vector2( 330f, 200f );

		window.Show();
	}

	private void OnEnable()
	{
		GetPrefs();

		Selection.selectionChanged += Repaint;
		EditorApplication.update += OnUpdate;
	}

	private void OnDisable()
	{
		Selection.selectionChanged -= Repaint;
		EditorApplication.update -= OnUpdate;
	}

	private void OnUpdate()
	{
		Transform selection = Selection.activeTransform;
		if( !IsNull( selection ) )
		{
			Vector3 pos = selection.localPosition;
			Vector3 rot = selection.localEulerAngles;

			if( pos != selectionPrevPos || rot != selectionPrevRot )
			{
				Repaint();

				selectionPrevPos = pos;
				selectionPrevRot = rot;
			}
		}
	}

	private void OnGUI()
	{
		if( buttonStyle == null )
		{
			buttonStyle = new GUIStyle( GUI.skin.button ) { richText = true };
			headerStyle = new GUIStyle( GUI.skin.box ) { alignment = TextAnchor.MiddleCenter };
		}

		scrollPos = EditorGUILayout.BeginScrollView( scrollPos );

		GUILayout.Box( "ADJUST PIVOT", headerStyle, GUILayout.ExpandWidth( true ), headerHeight );

		Transform selection = Selection.activeTransform;
		if( !IsNull( selection ) )
		{
			if( !IsNull( selection.parent ) )
			{
				if( selection.localPosition != Vector3.zero || selection.localEulerAngles != Vector3.zero )
				{
					if( GUILayout.Button( "Move <b>" + selection.parent.name + "</b>'s pivot here", buttonStyle, buttonHeight ) )
						SetParentPivot( selection );
				}
				else
				{
					GUI.enabled = false;
					GUILayout.Button( "Selected object is at pivot position", buttonStyle, buttonHeight );
					GUI.enabled = true;
				}
			}
			else
			{
				GUI.enabled = false;
				GUILayout.Button( "Selected object has no parent", buttonStyle, buttonHeight );
				GUI.enabled = true;
			}
		}
		else
		{
			GUI.enabled = false;
			GUILayout.Button( "Nothing is selected", buttonStyle, buttonHeight );
			GUI.enabled = true;
		}

		GUILayout.Space( 15f );

		GUILayout.Box( "MESH UTILITY", headerStyle, GUILayout.ExpandWidth( true ), headerHeight );

		EditorGUILayout.HelpBox( "If an object has a MeshFilter, changing its pivot will modify the mesh. That modified mesh must be saved before it can be applied to prefab.", MessageType.None );

		if( !IsNull( selection ) )
		{
			MeshFilter meshFilter = selection.GetComponent<MeshFilter>();
			if( !IsNull( meshFilter ) && !IsNull( meshFilter.sharedMesh ) )
			{
				if( GUILayout.Button( "Save <b>" + selection.name + "</b>'s mesh as Asset (Recommended)", buttonStyle, buttonHeight ) )
					SaveMesh( meshFilter, true );

				GUILayout.Space( 5f );

				if( GUILayout.Button( "Save <b>" + selection.name + "</b>'s mesh as OBJ", buttonStyle, buttonHeight ) )
					SaveMesh( meshFilter, false );
			}
			else
			{
				GUI.enabled = false;
				GUILayout.Button( "Selected object has no mesh", buttonStyle, buttonHeight );
				GUI.enabled = true;
			}
		}
		else
		{
			GUI.enabled = false;
			GUILayout.Button( "Nothing is selected", buttonStyle, buttonHeight );
			GUI.enabled = true;
		}

		GUILayout.Space( 15f );

		GUILayout.Box( "SETTINGS", headerStyle, GUILayout.ExpandWidth( true ), headerHeight );

		EditorGUI.BeginChangeCheck();
		createColliderObjectOnPivotChange = EditorGUILayout.ToggleLeft( "Create Child Collider Object On Pivot Change", createColliderObjectOnPivotChange );
		EditorGUILayout.HelpBox( "Note that original collider(s) (if exists) will not be destroyed automatically.", MessageType.None );
		if( EditorGUI.EndChangeCheck() )
			EditorPrefs.SetBool( "AdjustPivotCreateColliders", createColliderObjectOnPivotChange );

		GUILayout.Space( 10f );

		EditorGUI.BeginChangeCheck();
		createNavMeshObstacleObjectOnPivotChange = EditorGUILayout.ToggleLeft( "Create Child NavMesh Obstacle Object On Pivot Change", createNavMeshObstacleObjectOnPivotChange );
		EditorGUILayout.HelpBox( "Note that original NavMesh Obstacle (if exists) will not be destroyed automatically.", MessageType.None );
		if( EditorGUI.EndChangeCheck() )
			EditorPrefs.SetBool( "AdjustPivotCreateNavMeshObstacle", createNavMeshObstacleObjectOnPivotChange );

		GUILayout.Space( 10f );

		EditorGUILayout.EndScrollView();
	}

	private void GetPrefs()
	{
		createColliderObjectOnPivotChange = EditorPrefs.GetBool( "AdjustPivotCreateColliders", false );
		createNavMeshObstacleObjectOnPivotChange = EditorPrefs.GetBool( "AdjustPivotCreateNavMeshObstacle", false );
	}

	private void SetParentPivot( Transform pivot )
	{
		Transform pivotParent = pivot.parent;
		if( IsPrefab( pivotParent ) )
		{
			Debug.LogWarning( "Modifying prefabs directly is not allowed, create an instance in the scene instead!" );
			return;
		}

		if( pivot.localPosition == Vector3.zero && pivot.localEulerAngles == Vector3.zero )
		{
			Debug.LogWarning( "Pivot hasn't changed!" );
			return;
		}

		MeshFilter meshFilter = pivotParent.GetComponent<MeshFilter>();
		Mesh originalMesh = null;
		if( !IsNull( meshFilter ) && !IsNull( meshFilter.sharedMesh ) )
		{
			Undo.RecordObject( meshFilter, UNDO_ADJUST_PIVOT );

			originalMesh = meshFilter.sharedMesh;
			Mesh mesh = Instantiate( meshFilter.sharedMesh );
			meshFilter.sharedMesh = mesh;

			Vector3[] vertices = mesh.vertices;
			Vector3[] normals = mesh.normals;
			Vector4[] tangents = mesh.tangents;

			if( pivot.localPosition != Vector3.zero )
			{
				Vector3 deltaPosition = -pivot.localPosition;
				for( int i = 0; i < vertices.Length; i++ )
					vertices[i] += deltaPosition;
			}

			if( pivot.localEulerAngles != Vector3.zero )
			{
				Quaternion deltaRotation = Quaternion.Inverse( pivot.localRotation );
				for( int i = 0; i < vertices.Length; i++ )
				{
					vertices[i] = deltaRotation * vertices[i];
					normals[i] = deltaRotation * normals[i];

					Vector3 tangentDir = deltaRotation * tangents[i];
					tangents[i] = new Vector4( tangentDir.x, tangentDir.y, tangentDir.z, tangents[i].w );
				}
			}

			mesh.vertices = vertices;
			mesh.normals = normals;
			mesh.tangents = tangents;

			mesh.RecalculateBounds();
		}

		GetPrefs();

		Collider[] colliders = pivotParent.GetComponents<Collider>();
		foreach( Collider collider in colliders )
		{
			MeshCollider meshCollider = collider as MeshCollider;
			if( !IsNull( meshCollider ) && !IsNull( originalMesh ) && meshCollider.sharedMesh == originalMesh )
			{
				Undo.RecordObject( meshCollider, UNDO_ADJUST_PIVOT );
				meshCollider.sharedMesh = meshFilter.sharedMesh;
			}
		}

		if( createColliderObjectOnPivotChange && IsNull( pivotParent.Find( GENERATED_COLLIDER_NAME ) ) )
		{
			GameObject colliderObj = null;
			foreach( Collider collider in colliders )
			{
				if( IsNull( collider ) )
					continue;

				MeshCollider meshCollider = collider as MeshCollider;
				if( IsNull( meshCollider ) || meshCollider.sharedMesh != meshFilter.sharedMesh )
				{
					if( colliderObj == null )
					{
						colliderObj = new GameObject( GENERATED_COLLIDER_NAME );
						colliderObj.transform.SetParent( pivotParent, false );
					}

					EditorUtility.CopySerialized( collider, colliderObj.AddComponent( collider.GetType() ) );
				}
			}

			if( colliderObj != null )
				Undo.RegisterCreatedObjectUndo( colliderObj, UNDO_ADJUST_PIVOT );
		}

		if( createNavMeshObstacleObjectOnPivotChange && IsNull( pivotParent.Find( GENERATED_NAVMESH_OBSTACLE_NAME ) ) )
		{
			NavMeshObstacle obstacle = pivotParent.GetComponent<NavMeshObstacle>();
			if( !IsNull( obstacle ) )
			{
				GameObject obstacleObj = new GameObject( GENERATED_NAVMESH_OBSTACLE_NAME );
				obstacleObj.transform.SetParent( pivotParent, false );
				EditorUtility.CopySerialized( obstacle, obstacleObj.AddComponent( obstacle.GetType() ) );
				Undo.RegisterCreatedObjectUndo( obstacleObj, UNDO_ADJUST_PIVOT );
			}
		}

		Transform[] children = new Transform[pivotParent.childCount];
		Vector3[] childrenLocalScales = new Vector3[children.Length];
		for( int i = children.Length - 1; i >= 0; i-- )
		{
			children[i] = pivotParent.GetChild( i );
			childrenLocalScales[i] = children[i].localScale;

			Undo.RecordObject( children[i], UNDO_ADJUST_PIVOT );
			children[i].SetParent( null, true );
		}

		Undo.RecordObject( pivotParent, UNDO_ADJUST_PIVOT );
		pivotParent.position = pivot.position;
		pivotParent.rotation = pivot.rotation;

		for( int i = 0; i < children.Length; i++ )
		{
			children[i].SetParent( pivotParent, true );
			children[i].localScale = childrenLocalScales[i];
		}

		pivot.localPosition = Vector3.zero;
		pivot.localRotation = Quaternion.identity;
	}

	private void SaveMesh( MeshFilter meshFilter, bool saveAsAsset )
	{
		if( IsPrefab( meshFilter ) )
		{
			Debug.LogWarning( "Modifying prefabs directly is not allowed, create an instance in the scene instead!" );
			return;
		}

		string savedMeshName = meshFilter.sharedMesh.name;
		while( savedMeshName.EndsWith( "(Clone)" ) )
			savedMeshName = savedMeshName.Substring( 0, savedMeshName.Length - 7 );

		string savePath = EditorUtility.SaveFilePanelInProject( "Save As", savedMeshName, saveAsAsset ? "asset" : "obj", string.Empty );
		if( string.IsNullOrEmpty( savePath ) )
			return;

		Mesh originalMesh = meshFilter.sharedMesh;
		Mesh savedMesh = saveAsAsset ? SaveMeshAsAsset( meshFilter, savePath ) : SaveMeshAsOBJ( meshFilter, savePath );
		if( meshFilter.sharedMesh != savedMesh )
		{
			Undo.RecordObject( meshFilter, UNDO_SAVE_MODEL_AS );
			meshFilter.sharedMesh = savedMesh;
		}

		MeshCollider[] meshColliders = meshFilter.GetComponents<MeshCollider>();
		foreach( MeshCollider meshCollider in meshColliders )
		{
			if( !IsNull( meshCollider ) && meshCollider.sharedMesh == originalMesh && meshCollider.sharedMesh != savedMesh )
			{
				Undo.RecordObject( meshCollider, UNDO_SAVE_MODEL_AS );
				meshCollider.sharedMesh = savedMesh;
			}
		}
	}

	private Mesh SaveMeshAsAsset( MeshFilter meshFilter, string savePath )
	{
		Mesh mesh = meshFilter.sharedMesh;
		if( !string.IsNullOrEmpty( AssetDatabase.GetAssetPath( mesh ) ) ) // If mesh is an asset, clone it
			mesh = Instantiate( mesh );

		AssetDatabase.CreateAsset( mesh, savePath );
		AssetDatabase.SaveAssets();

		return mesh;
	}

	//Credit: http://wiki.unity3d.com/index.php?title=ObjExporter
	private Mesh SaveMeshAsOBJ( MeshFilter meshFilter, string savePath )
	{
		Mesh mesh = meshFilter.sharedMesh;

		Renderer renderer = meshFilter.GetComponent<Renderer>();
		Material[] mats = !IsNull( renderer ) ? renderer.sharedMaterials : null;

		StringBuilder meshString = new StringBuilder();

		meshString.Append( "g " ).Append( Path.GetFileNameWithoutExtension( savePath ) ).Append( "\n" );
		foreach( Vector3 v in mesh.vertices )
			meshString.Append( string.Format( "v {0} {1} {2}\n", -v.x, v.y, v.z ) );

		meshString.Append( "\n" );

		foreach( Vector3 v in mesh.normals )
			meshString.Append( string.Format( "vn {0} {1} {2}\n", -v.x, v.y, v.z ) );

		meshString.Append( "\n" );

		foreach( Vector3 v in mesh.uv )
			meshString.Append( string.Format( "vt {0} {1}\n", v.x, v.y ) );

		for( int material = 0; material < mesh.subMeshCount; material++ )
		{
			meshString.Append( "\n" );

			if( mats != null && mats.Length > material )
			{
				meshString.Append( "usemtl " ).Append( mats[material].name ).Append( "\n" );
				meshString.Append( "usemap " ).Append( mats[material].name ).Append( "\n" );
			}

			int[] triangles = mesh.GetTriangles( material );
			for( int i = 0; i < triangles.Length; i += 3 )
			{
				meshString.Append( string.Format( "f {1}/{1}/{1} {0}/{0}/{0} {2}/{2}/{2}\n",
					triangles[i] + 1, triangles[i + 1] + 1, triangles[i + 2] + 1 ) );
			}
		}

		File.WriteAllText( savePath, meshString.ToString() );
		AssetDatabase.ImportAsset( savePath, ImportAssetOptions.ForceUpdate );

		return AssetDatabase.LoadAssetAtPath<Mesh>( savePath );
	}

	private bool IsPrefab( Object obj )
	{
		PrefabType prefabType = PrefabUtility.GetPrefabType( obj );
		return prefabType == PrefabType.Prefab || prefabType == PrefabType.ModelPrefab;
	}

	private bool IsNull( Object obj )
	{
		return obj == null || obj.Equals( null );
	}
}