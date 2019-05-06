package com.horstmann.violet.product.diagram.classes.node;


import java.beans.PropertyDescriptor;
import java.util.List;

import com.horstmann.violet.product.diagram.abstracts.node.AbstractNodeBeanInfo;
import com.horstmann.violet.product.diagram.classes.ClassDiagramConstant;

/**
 * The bean info for the ClassNode type.
 */
public class EnumNodeBeanInfo extends AbstractNodeBeanInfo
{
    public EnumNodeBeanInfo()
    {
        super(EnumNode.class);
        addResourceBundle(ClassDiagramConstant.CLASS_DIAGRAM_STRINGS);
    }

    @Override
    protected List<PropertyDescriptor> createPropertyDescriptorList()
    {
        List<PropertyDescriptor> propertyDescriptorList = super.createPropertyDescriptorList();

        propertyDescriptorList.add(createPropertyDescriptor(NAME_VAR_NAME, NAME_LABEL_KEY, 1));
        propertyDescriptorList.add(createPropertyDescriptor(ATTRIBUTES_VAR_NAME, ATTRIBUTES_LABEL_KEY, 2));

        return propertyDescriptorList;
    }

    protected static final String NAME_LABEL_KEY = "enum.name";
    protected static final String ATTRIBUTES_LABEL_KEY = "enum.attributes";
    private static final String NAME_VAR_NAME = "name";
    private static final String ATTRIBUTES_VAR_NAME = "attributes";
}