#pragma once
#include <Functions/IFunctionDateOrDateTime.h>

namespace DB
{

namespace ErrorCodes
{
    extern const int ILLEGAL_TYPE_OF_ARGUMENT;
}

template <typename Transform>
class FunctionDateOrDateTimeToDateTimeOrDateTime64 : public IFunctionDateOrDateTime<Transform>, WithContext
{
public:
    const bool enable_extended_results_for_datetime_functions = false;

    static FunctionPtr create(ContextPtr context_)
    {
        return std::make_shared<FunctionDateOrDateTimeToDateTimeOrDateTime64>(context_);
    }

    explicit FunctionDateOrDateTimeToDateTimeOrDateTime64(ContextPtr context_)
        : WithContext(context_)
        , enable_extended_results_for_datetime_functions(context_->getSettingsRef().enable_extended_results_for_datetime_functions)
    {
    }

    DataTypePtr getReturnTypeImpl(const ColumnsWithTypeAndName & arguments) const override
    {
        this->checkArguments(arguments, /*is_result_type_date_or_date32*/ true);

        const IDataType * from_type = arguments[0].type.get();
        WhichDataType which(from_type);

        /// If the time zone is specified but empty, throw an exception.
        /// only validate the time_zone part if the number of arguments is 2.
        if ((which.isDateTime() || which.isDateTime64()) && arguments.size() == 2
            && extractTimeZoneNameFromFunctionArguments(arguments, 1, 0).empty())
            throw Exception(
                "Function " + this->getName() + " supports a 2nd argument (optional) that must be non-empty and be a valid time zone",
                ErrorCodes::ILLEGAL_TYPE_OF_ARGUMENT);

        if ((which.isDate32() || which.isDateTime64()) && enable_extended_results_for_datetime_functions)
        {
            Int64 scale = DataTypeDateTime64::default_scale;
            if (which.isDateTime64())
            {
                if (const auto * dt64 =  checkAndGetDataType<DataTypeDateTime64>(arguments[0].type.get()))
                    scale = dt64->getScale();
            }
            return std::make_shared<DataTypeDateTime64>(scale, extractTimeZoneNameFromFunctionArguments(arguments, 1, 0));
        }
        else
            return std::make_shared<DataTypeDateTime>();
    }

    ColumnPtr executeImpl(const ColumnsWithTypeAndName & arguments, const DataTypePtr & result_type, size_t input_rows_count) const override
    {
        const IDataType * from_type = arguments[0].type.get();
        WhichDataType which(from_type);
        if (which.isDate())
            return DateTimeTransformImpl<DataTypeDate, DataTypeDateTime, Transform>::execute(arguments, result_type, input_rows_count);
        else if (which.isDate32())
            if (enable_extended_results_for_datetime_functions)
                return DateTimeTransformImpl<DataTypeDate32, DataTypeDateTime64, Transform, /*is_extended_result*/ true>::execute(arguments, result_type, input_rows_count);
            else
                return DateTimeTransformImpl<DataTypeDate32, DataTypeDateTime, Transform>::execute(arguments, result_type, input_rows_count);
        else
        if (which.isDateTime())
            return DateTimeTransformImpl<DataTypeDateTime, DataTypeDateTime, Transform>::execute(arguments, result_type, input_rows_count);
        else if (which.isDateTime64())
        {
            const auto scale = static_cast<const DataTypeDateTime64 *>(from_type)->getScale();

            const TransformDateTime64<Transform> transformer(scale);
            if (enable_extended_results_for_datetime_functions)
                return DateTimeTransformImpl<DataTypeDateTime64, DataTypeDateTime64, decltype(transformer), /*is_extended_result*/ true>::execute(arguments, result_type, input_rows_count, transformer);
            else
                return DateTimeTransformImpl<DataTypeDateTime64, DataTypeDateTime, decltype(transformer)>::execute(arguments, result_type, input_rows_count, transformer);
        }
        else
            throw Exception("Illegal type " + arguments[0].type->getName() + " of argument of function " + this->getName(),
                ErrorCodes::ILLEGAL_TYPE_OF_ARGUMENT);
    }

};

}
