/*******************************************************************************
 * Copyright (c) 2008 Heiko Seeberger and others.
 * All rights reserved. This program and the accompanying materials 
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html.
 * 
 * Contributors:
 *     Heiko Seeberger - initial implementation
 ******************************************************************************/

package net.orcades.eclipse.wtppatch.weaving;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.IPath;
import org.eclipse.wst.common.componentcore.internal.flat.FlatVirtualComponent;
import org.eclipse.wst.common.componentcore.internal.flat.VirtualComponentFlattenUtility;
import org.eclipse.wst.common.componentcore.resources.IVirtualComponent;
import org.eclipse.wst.common.componentcore.resources.IVirtualReference;

/**
 * Short WTP fix.
 * 
 * @author olivier.nouguier@gmail.com
 */
privileged aspect FlatVirtualComponentAspect {
	// TODO make it match || avoid constructor aop ?
	pointcut buggy(VirtualComponentFlattenUtility util, IVirtualComponent vc,
			IPath root): cflowbelow(execution(void FlatVirtualComponent.treeWalk())) && execution(void FlatVirtualComponent.addUsedReferences(VirtualComponentFlattenUtility, IVirtualComponent, IPath)) && args(util, vc, root);

	void around(VirtualComponentFlattenUtility util, IVirtualComponent vc,
			IPath root) :  buggy(util, vc, root)
      {
		Map options = new HashMap();
		options.put("REQUESTED_REFERENCE_TYPE", "FLATTENABLE_REFERENCES");
		IVirtualReference[] allReferences = vc.getReferences(options);

		for (IVirtualReference iVirtualReference : allReferences) {

			if (iVirtualReference.getArchiveName() == null) {
				System.out.println("Fixed: "
						+ iVirtualReference.getEnclosingComponent() + " "
						+ iVirtualReference.getReferencedComponent());
				iVirtualReference.setArchiveName("");
			}
		}

		proceed(util, vc, root);

	}

}
