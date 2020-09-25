/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2020 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * Described in http://www.fractalforums.com/general-discussion-b77/solids-many-many-solids/
 * fold and cut regular polyhedra Distance Estimator (knighty 2012)

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_transf_difs_polyhedra.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TransfDIFSPolyhedraIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	int Type = fractal->transformCommon.int3;
	// U 'barycentric' coordinate for the 'principal' node
	REAL U = fractal->transformCommon.constantMultiplier100.x;
	REAL V = fractal->transformCommon.constantMultiplier100.y;
	REAL W = fractal->transformCommon.constantMultiplier100.z;
	// vertex radius
	REAL VRadius = fractal->transformCommon.offset01;
	// segments radius
	REAL SRadius = fractal->transformCommon.offsetp05;

	REAL temp;
	// this block does not use z so could be inline precalc
	REAL cospin = M_PI_F / (REAL)(Type);
	cospin = native_cos(cospin);
	REAL scospin = native_sqrt(0.75f - cospin * cospin);
	REAL4 nc = (REAL4){-0.5f, -cospin, scospin, 0.0f};
	REAL4 pab = (REAL4){0.0f, 0.0f, 1.0f, 0.0f};
	REAL4 pbc = (REAL4){scospin, 0.0f, 0.5f, 0.0f};
	temp = length(pbc);
	pbc = pbc / temp;
	REAL4 pca = (REAL4){0.0f, scospin, cospin, 0.0f};
	temp = length(pca);
	pca = pca / temp;

	REAL4 p = (U * pab + V * pbc + W * pca);
	temp = length(p);
	p = p / temp;

	REAL d = 10000.0f;
	REAL4 colVec = (REAL4){1000.0f, 1000.0f, 1000.0f, 1000.0f};
	REAL4 zc = z * fractal->transformCommon.scale1;
	aux->DE = aux->DE * fractal->transformCommon.scale1;

	for (int n = 0; n < Type; n++)
	{
		zc.x = fabs(zc.x);
		zc.y = fabs(zc.y);
		REAL t = -2.0f * min(0.0f, dot(zc, nc));
		zc += t * nc;
	}
	REAL4 zcv = zc;
	if (!fractal->transformCommon.functionEnabledBxFalse)
	{ // faces
		REAL d0 = dot(zc, pab) - dot(p, pab);
		REAL d1 = dot(zc, pbc) - dot(p, pbc);
		REAL d2 = dot(zc, pca) - dot(p, pca);
		REAL df = max(max(d0, d1), d2);
		colVec.x = df;
		d = min(d, df);
	}

	if (!fractal->transformCommon.functionEnabledByFalse)
	{ // Segments
		zc -= p;
		REAL4 temp4 = zc - min(0.0f, zc.x) * (REAL4){1.0f, 0.0f, 0.0f, 0.0f};
		REAL dla = length(temp4);
		temp4 = zc - min(0.0f, zc.y) * (REAL4){0.0f, 1.0f, 0.0f, 0.0f};
		REAL dlb = length(temp4);
		temp4 = zc - min(0.0f, dot(zc, nc)) * nc;
		REAL dlc = length(temp4);
		REAL ds = min(min(dla, dlb), dlc) - SRadius;
		colVec.y = ds;
		d = min(d, ds);
	}

	if (!fractal->transformCommon.functionEnabledBzFalse)
	{ // Vertices
		REAL dv;
		if (!fractal->transformCommon.functionEnabledDFalse)
		{
			REAL4 temp4 = zcv - p;
			dv = length(temp4) - VRadius;
		}
		else
		{
			REAL4 ff = fabs(zcv - p);
			dv = max(max(ff.x, ff.y), ff.z) - VRadius;
		}
		colVec.z = dv;
		d = min(d, dv);
	}

	aux->dist = min(aux->dist, d) / aux->DE;
	if (fractal->transformCommon.functionEnabledzFalse) z = zc;

	if (fractal->foldColor.auxColorEnabled)
	{
		colVec.x *= fractal->foldColor.difs0000.x;
		colVec.y *= fractal->foldColor.difs0000.y;
		colVec.z *= fractal->foldColor.difs0000.z;
		if (!fractal->foldColor.auxColorEnabledFalse)
		{
			REAL colorAdd = 0.0f;
			colorAdd += colVec.x;
			colorAdd += colVec.y;
			colorAdd += colVec.z;
			// colorAdd += colVec.w;
			aux->color = colorAdd * 256.0f;
		}
		else
		{
			aux->color = min(min(colVec.x, colVec.y), colVec.z) * fractal->foldColor.difs1 * 1024.0f;
		}
	}
	return z;
}
