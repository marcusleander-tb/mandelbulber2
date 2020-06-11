/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2020 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * testing log

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_testing_log.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TestingLogIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{

	REAL colorAdd = 0.0;

	REAL4 ColV = (REAL4)(0.0, 0.0, 0.0, 0.0);

	//REAL tp = fractal->transformCommon.offset1;
	REAL t = fractal->transformCommon.minR06;
	REAL4 t1 = (REAL4)(SQRT_3_4, -0.5, 0.0, 0.0);
	REAL4 t2 = (REAL4)(-SQRT_3_4, -0.5, 0.0, 0.0);

	REAL4 n1 = (REAL4)(-0.5, -SQRT_3_4, 0.0, 0.0);
	REAL4 n2 = (REAL4)(-0.5, SQRT_3_4, 0.0, 0.0);
	REAL scale2 = fractal->transformCommon.scale2;
	// adjusting this can help with the stepping scheme, but doesn't affect geometry.

	REAL innerScale = SQRT_3 / (1.0 + SQRT_3);
	REAL innerScaleB = innerScale * innerScale * 0.25;

	//for (int i = 0; i < fractal->transformCommon.int8X && dot(z, z) < 0.5; i++)
	for (int i = 0; i < fractal->transformCommon.int8X; i++)
	{
		if (!fractal->transformCommon.functionEnabledBxFalse)
		{
			REAL4 zB = z - (REAL4)(0.0, 0.0, innerScale * 0.5, 0.0);
			if (dot(zB, zB) < innerScaleB) break; // definitely inside
		}


		REAL maxH = 0.4 * fractal->transformCommon.scaleG1;
		if (i == 0) maxH = -100;

		REAL4 zC = z - (REAL4)(0.0, 0.0, t, 0.0);
		if (z.z > maxH && dot(zC, zC) > t * t) break; // definitely outside

		REAL4 zD = z - (REAL4)(0.0, 0.0, 0.5, 0.0);
		REAL invSC = 1.0 / dot(z, z) * fractal->transformCommon.scaleF1;

		if (z.z < maxH && dot(zD, zD) > 0.5 * 0.5)
		{
			// needs a sphere inverse
			aux->DE *= invSC;
			z *= invSC;
			ColV.x += 1.0;
		}
		else
		{
			// stretch onto a plane at zero
			ColV.y += 1.0;
			aux->DE *= invSC;
			z *= invSC;
			z.z -= 1.0;
			z.z *= -1.0;
			z *= SQRT_3;
			aux->DE *= SQRT_3;
			z.z += 1.0;

		// and rotate it a twelfth of a revolution
			REAL a = M_PI / (REAL)(fractal->transformCommon.int6);
			REAL cosA = cos(a);
			REAL sinA = sin(a);
			REAL xx = z.x * cosA + z.y * sinA;
			REAL yy = -z.x * sinA + z.y * cosA;
			z.x = xx;
			z.y = yy;
		}

		// now modolu the space so we move to being in just the central hexagon, inner radius 0.5

		REAL h = z.z;

		REAL x = dot(z, -n2) * fractal->transformCommon.scaleA2 / SQRT_3;
		REAL y = dot(z, -n1) * fractal->transformCommon.scaleA2 / SQRT_3;
		x = x - floor(x);
		y = y - floor(y);


		if (x + y > 1.0)
		{
			x = 1.0 - x;
			y = 1.0 - y;
		// aux->color += 2.0;
		}

		z = x * t1 - y * t2;


		// fold the space to be in a kite

		REAL l0 = dot(z, z);
		REAL l1 = dot(z - t1, z - t1);
		REAL l2 = dot(z + t2, z + t2);

		if (l1 < l0 && l1 < l2)
		{
			z -= t1 * (2.0 * dot(t1, z) - 1.0);

			ColV.z += 1.0;

		}

		else if (l2 < l0 && l2 < l1)
		{
			z -= t2 * (2.0 * dot(z, t2) + 1.0);
			ColV.w += 1.0;
		}

		z.z = h;
		//REAL pp = -.2;
		//if ( i % 2 == 0) pp = 0.0;
		//z += fractal->transformCommon.offset000 + pp;

		}
	// aux->DE =  scale2;

	REAL d = (length(z - (REAL4)(0.0, 0.0, 0.4, 0.0)) - 0.4);
	if (fractal->analyticDE.enabledFalse)	d = (sqrt(d + 1.0) - 1) * 2.0;
	d /=			  (scale2 * aux->DE); // the 0.4 is slightly more averaging than 0.5

	aux->dist = min(aux->dist, d);

	// aux.color
	if (fractal->foldColor.auxColorEnabledFalse)
	{ //double colorAdd = 0.0;
		colorAdd += colorAdd * fractal->foldColor.difs1;
		colorAdd += ColV.x * fractal->foldColor.difs0000.x;
		colorAdd += ColV.y * fractal->foldColor.difs0000.y;
		colorAdd += ColV.z * fractal->foldColor.difs0000.z;
		colorAdd += ColV.w * fractal->foldColor.difs0000.w;


		aux->color += colorAdd;
	}


	return z;
}
