import SectionUI

func createListSection() -> SKCSingleTypeSection<ColorCell> {
    let colors: [UIColor] = [.red, .green, .blue]

    return ColorCell.wrapperToSingleTypeSection(colors)
        .onCellAction(.selected) { context in
            print("Selected color: \(context.model)")
        }
        .setSectionStyle { section in
            section.minimumLineSpacing = 10
            section.sectionInset = .init(top: 10, left: 16, bottom: 10, right: 16)
        }
}
