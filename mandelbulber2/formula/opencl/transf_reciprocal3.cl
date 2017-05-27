/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2017 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * Reciprocal3  based on Darkbeam's code from M3D,
 * @reference
 * http://www.fractalforums.com/mandelbulb-3d/custom-formulas-and-transforms-release-t17106/
 */

/* ### This file has been autogenerated. Remove this line, to prevent override. ### */

#ifndef DOUBLE_PRECISION
void TransfReciprocal3Iteration(float4 *z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	float4 tempZ = *z;

	if (fractal->transformCommon.functionEnabledx)
	{
		if (fractal->transformCommon.functionEnabledAx)
			tempZ.x = (native_recip(fractal->transformCommon.offset111.x))
								- native_recip((fabs(z->x) + fractal->transformCommon.offset111.x));

		if (fractal->transformCommon.functionEnabledAxFalse)
			tempZ.x = (fractal->transformCommon.offsetA111.x)
								- native_recip((fabs(z->x) + fractal->transformCommon.offset111.x));

		if (fractal->transformCommon.functionEnabledBxFalse)
		{
			float M1 = fractal->transformCommon.scale1;
			float M2 = fractal->transformCommon.scaleA1;
			tempZ.x = (native_recip(fractal->transformCommon.offset111.x))
								+ (native_recip(fractal->transformCommon.offsetA111.x))
								- native_recip((fabs(z->x * M1) + fractal->transformCommon.offset111.x))
								- native_recip(((z->x * z->x * M2) + fractal->transformCommon.offsetA111.x));
		}
		if (fractal->transformCommon.functionEnabledCxFalse)
		{
			float M1 = fractal->transformCommon.scale1;
			float M2 = fractal->transformCommon.scaleA1;
			tempZ.x = fractal->transformCommon.offsetB111.x
								- native_recip((fabs(z->x * M1) + fractal->transformCommon.offset111.x))
								- native_recip(((z->x * z->x * M2) + fractal->transformCommon.offsetA111.x));
		}

		tempZ.x += fabs(z->x) * fractal->transformCommon.offset000.x; // function slope
		z->x = copysign(tempZ.x, z->x);
	}

	if (fractal->transformCommon.functionEnabledy)
	{
		if (fractal->transformCommon.functionEnabledAx)
			tempZ.y = (native_recip(fractal->transformCommon.offset111.y))
								- native_recip((fabs(z->y) + fractal->transformCommon.offset111.y));

		if (fractal->transformCommon.functionEnabledAxFalse)
			tempZ.y = (fractal->transformCommon.offsetA111.y)
								- native_recip((fabs(z->y) + fractal->transformCommon.offset111.y));

		if (fractal->transformCommon.functionEnabledBxFalse)
		{
			float M1 = fractal->transformCommon.scale1;
			float M2 = fractal->transformCommon.scaleA1;
			tempZ.y = (native_recip(fractal->transformCommon.offset111.y))
								+ (native_recip(fractal->transformCommon.offsetA111.y))
								- native_recip((fabs(z->y * M1) + fractal->transformCommon.offset111.y))
								- native_recip(((z->y * z->y * M2) + fractal->transformCommon.offsetA111.y));
		}

		if (fractal->transformCommon.functionEnabledCxFalse)
		{
			float M1 = fractal->transformCommon.scale1;
			float M2 = fractal->transformCommon.scaleA1;
			tempZ.y = fractal->transformCommon.offsetB111.y
								- native_recip((fabs(z->y * M1) + fractal->transformCommon.offset111.y))
								- native_recip(((z->y * z->y * M2) + fractal->transformCommon.offsetA111.y));
		}
		tempZ.y += fabs(z->y) * fractal->transformCommon.offset000.y;
		z->y = copysign(tempZ.y, z->y);
	}

	if (fractal->transformCommon.functionEnabledz)
	{
		if (fractal->transformCommon.functionEnabledAx)
			tempZ.z = (native_recip(fractal->transformCommon.offset111.z))
								- native_recip((fabs(z->z) + fractal->transformCommon.offset111.z));

		if (fractal->transformCommon.functionEnabledAxFalse)
			tempZ.z = (fractal->transformCommon.offsetA111.z)
								- native_recip((fabs(z->z) + fractal->transformCommon.offset111.z));

		if (fractal->transformCommon.functionEnabledBxFalse)
		{
			float M1 = fractal->transformCommon.scale1;
			float M2 = fractal->transformCommon.scaleA1;
			tempZ.z = (native_recip(fractal->transformCommon.offset111.z))
								+ (native_recip(fractal->transformCommon.offsetA111.z))
								- native_recip((fabs(z->z * M1) + fractal->transformCommon.offset111.z))
								- native_recip(((z->z * z->z * M2) + fractal->transformCommon.offsetA111.z));
		}
		if (fractal->transformCommon.functionEnabledCxFalse)
		{
			float M1 = fractal->transformCommon.scale1;
			float M2 = fractal->transformCommon.scaleA1;
			tempZ.z = fractal->transformCommon.offsetB111.z
								- native_recip((fabs(z->z * M1) + fractal->transformCommon.offset111.z))
								- native_recip(((z->z * z->z * M2) + fractal->transformCommon.offsetA111.z));
		}

		tempZ.z += fabs(z->z) * fractal->transformCommon.offset000.z;
		z->z = copysign(tempZ.z, z->z);
	}
	// aux->DE = aux->DE * l/L;
	aux->DE *= fractal->analyticDE.scale1; // DE tweak
}
#else
void TransfReciprocal3Iteration(double4 *z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	double4 tempZ = *z;

	if (fractal->transformCommon.functionEnabledx)
	{
		if (fractal->transformCommon.functionEnabledAx)
			tempZ.x = (1.0 / fractal->transformCommon.offset111.x)
								- 1.0 / (fabs(z->x) + fractal->transformCommon.offset111.x);

		if (fractal->transformCommon.functionEnabledAxFalse)
			tempZ.x = (fractal->transformCommon.offsetA111.x)
								- 1.0 / (fabs(z->x) + fractal->transformCommon.offset111.x);

		if (fractal->transformCommon.functionEnabledBxFalse)
		{
			double M1 = fractal->transformCommon.scale1;
			double M2 = fractal->transformCommon.scaleA1;
			tempZ.x = (1.0 / fractal->transformCommon.offset111.x)
								+ (1.0 / fractal->transformCommon.offsetA111.x)
								- 1.0 / (fabs(z->x * M1) + fractal->transformCommon.offset111.x)
								- 1.0 / ((z->x * z->x * M2) + fractal->transformCommon.offsetA111.x);
		}
		if (fractal->transformCommon.functionEnabledCxFalse)
		{
			double M1 = fractal->transformCommon.scale1;
			double M2 = fractal->transformCommon.scaleA1;
			tempZ.x = fractal->transformCommon.offsetB111.x
								- 1.0 / (fabs(z->x * M1) + fractal->transformCommon.offset111.x)
								- 1.0 / ((z->x * z->x * M2) + fractal->transformCommon.offsetA111.x);
		}

		tempZ.x += fabs(z->x) * fractal->transformCommon.offset000.x; // function slope
		z->x = copysign(tempZ.x, z->x);
	}

	if (fractal->transformCommon.functionEnabledy)
	{
		if (fractal->transformCommon.functionEnabledAx)
			tempZ.y = (1.0 / fractal->transformCommon.offset111.y)
								- 1.0 / (fabs(z->y) + fractal->transformCommon.offset111.y);

		if (fractal->transformCommon.functionEnabledAxFalse)
			tempZ.y = (fractal->transformCommon.offsetA111.y)
								- 1.0 / (fabs(z->y) + fractal->transformCommon.offset111.y);

		if (fractal->transformCommon.functionEnabledBxFalse)
		{
			double M1 = fractal->transformCommon.scale1;
			double M2 = fractal->transformCommon.scaleA1;
			tempZ.y = (1.0 / fractal->transformCommon.offset111.y)
								+ (1.0 / fractal->transformCommon.offsetA111.y)
								- 1.0 / (fabs(z->y * M1) + fractal->transformCommon.offset111.y)
								- 1.0 / ((z->y * z->y * M2) + fractal->transformCommon.offsetA111.y);
		}

		if (fractal->transformCommon.functionEnabledCxFalse)
		{
			double M1 = fractal->transformCommon.scale1;
			double M2 = fractal->transformCommon.scaleA1;
			tempZ.y = fractal->transformCommon.offsetB111.y
								- 1.0 / (fabs(z->y * M1) + fractal->transformCommon.offset111.y)
								- 1.0 / ((z->y * z->y * M2) + fractal->transformCommon.offsetA111.y);
		}
		tempZ.y += fabs(z->y) * fractal->transformCommon.offset000.y;
		z->y = copysign(tempZ.y, z->y);
	}

	if (fractal->transformCommon.functionEnabledz)
	{
		if (fractal->transformCommon.functionEnabledAx)
			tempZ.z = (1.0 / fractal->transformCommon.offset111.z)
								- 1.0 / (fabs(z->z) + fractal->transformCommon.offset111.z);

		if (fractal->transformCommon.functionEnabledAxFalse)
			tempZ.z = (fractal->transformCommon.offsetA111.z)
								- 1.0 / (fabs(z->z) + fractal->transformCommon.offset111.z);

		if (fractal->transformCommon.functionEnabledBxFalse)
		{
			double M1 = fractal->transformCommon.scale1;
			double M2 = fractal->transformCommon.scaleA1;
			tempZ.z = (1.0 / fractal->transformCommon.offset111.z)
								+ (1.0 / fractal->transformCommon.offsetA111.z)
								- 1.0 / (fabs(z->z * M1) + fractal->transformCommon.offset111.z)
								- 1.0 / ((z->z * z->z * M2) + fractal->transformCommon.offsetA111.z);
		}
		if (fractal->transformCommon.functionEnabledCxFalse)
		{
			double M1 = fractal->transformCommon.scale1;
			double M2 = fractal->transformCommon.scaleA1;
			tempZ.z = fractal->transformCommon.offsetB111.z
								- 1.0 / (fabs(z->z * M1) + fractal->transformCommon.offset111.z)
								- 1.0 / ((z->z * z->z * M2) + fractal->transformCommon.offsetA111.z);
		}

		tempZ.z += fabs(z->z) * fractal->transformCommon.offset000.z;
		z->z = copysign(tempZ.z, z->z);
	}
	// aux->DE = aux->DE * l/L;
	aux->DE *= fractal->analyticDE.scale1; // DE tweak
}
#endif
