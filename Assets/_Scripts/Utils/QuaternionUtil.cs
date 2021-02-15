using UnityEngine;

// Original Author: Max Kaufmann (max.kaufmann@gmail.com)

public static class QuaternionUtil {
	
	public static Quaternion AngVelToDeriv(Quaternion Current, Vector3 AngVel) {
		var Spin = new Quaternion(AngVel.x, AngVel.y, AngVel.z, 0f);
		var Result = Spin * Current;
		return new Quaternion(0.5f * Result.x, 0.5f * Result.y, 0.5f * Result.z, 0.5f * Result.w);
	} 

	public static Vector3 DerivToAngVel(Quaternion Current, Quaternion Deriv) {
		var Result = Deriv * Quaternion.Inverse(Current);
		return new Vector3(2f * Result.x, 2f * Result.y, 2f * Result.z);
	}

	public static Quaternion IntegrateRotation(Quaternion Rotation, Vector3 AngularVelocity, float DeltaTime) {
		var Deriv = AngVelToDeriv(Rotation, AngularVelocity);
		var Pred = new Vector4(
				Rotation.x + Deriv.x * DeltaTime,
				Rotation.y + Deriv.y * DeltaTime,
				Rotation.z + Deriv.z * DeltaTime,
				Rotation.w + Deriv.w * DeltaTime
		).normalized;
		return new Quaternion(Pred.x, Pred.y, Pred.z, Pred.w);
	}

	public static Quaternion QuaternionFromMatrix(Matrix4x4 m)
	{
		// Adapted from: http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
		Quaternion q = new Quaternion();
		q.w = Mathf.Sqrt(Mathf.Max(0, 1 + m[0, 0] + m[1, 1] + m[2, 2])) / 2;
		q.x = Mathf.Sqrt(Mathf.Max(0, 1 + m[0, 0] - m[1, 1] - m[2, 2])) / 2;
		q.y = Mathf.Sqrt(Mathf.Max(0, 1 - m[0, 0] + m[1, 1] - m[2, 2])) / 2;
		q.z = Mathf.Sqrt(Mathf.Max(0, 1 - m[0, 0] - m[1, 1] + m[2, 2])) / 2;
		q.x *= Mathf.Sign(q.x * (m[2, 1] - m[1, 2]));
		q.y *= Mathf.Sign(q.y * (m[0, 2] - m[2, 0]));
		q.z *= Mathf.Sign(q.z * (m[1, 0] - m[0, 1]));
		return q;
	}

	public static Quaternion SmoothDamp(Quaternion rot, Quaternion target, ref Quaternion deriv, float time) {
		// account for double-cover
		var Dot = Quaternion.Dot(rot, target);
		var Multi = Dot > 0f ? 1f : -1f;
		target.x *= Multi;
		target.y *= Multi;
		target.z *= Multi;
		target.w *= Multi;
		// smooth damp (nlerp approx)
		var Result = new Vector4(
			Mathf.SmoothDamp(rot.x, target.x, ref deriv.x, time),
			Mathf.SmoothDamp(rot.y, target.y, ref deriv.y, time),
			Mathf.SmoothDamp(rot.z, target.z, ref deriv.z, time),
			Mathf.SmoothDamp(rot.w, target.w, ref deriv.w, time)
		).normalized;
		// compute deriv
		var dtInv = 1f / Time.deltaTime;
		deriv.x = (Result.x - rot.x) * dtInv;
		deriv.y = (Result.y - rot.y) * dtInv;
		deriv.z = (Result.z - rot.z) * dtInv;
		deriv.w = (Result.w - rot.w) * dtInv;
		return new Quaternion(Result.x, Result.y, Result.z, Result.w);
	}
}